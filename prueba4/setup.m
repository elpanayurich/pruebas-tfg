function [R_AP_UE,R_AP_RIS1,R_AP_RIS2,R_RIS_UE,pilotIndex,D,HMean_AP_UE, HMean_AP_RIS, HMean_RIS_UE, probLoS_AP_UE, probLoS_RIS_UE] = setup(L,K,N_AP,N_RIS,tau_p,seed,ASD_varphi,LoS,fc,S)
%% Definir escenario
HMean_AP_UE = zeros(N_AP*L,K);          % Canal LoS AP-UE
HMean_RIS_UE = zeros(N_RIS*S,K);        % Canal LoS RIS-UE
HMean_AP_RIS = zeros(N_AP*L,N_RIS*S);   % Canal LoS AP-RIS


%Establecer el número de semilla si se especifica distinto de cero
if (nargin>4)&&(seed>0)
    rng(seed)
end

squareLength = 1000;    %Tamaño del área de cobertura
B = 20e6;   %Ancho de banda (Hz)
noiseFigure = 7;    % dB
noiseVariancedBm = -174 + 10*log10(B) + noiseFigure;    % Potencia de ruido calculada (dBm)
sigma_sf = 4;   %Desviación estándar del desvanecimiento de shadow
decorr = 9;    % Distancia de decorrelación del desvanecimiento de shadow

% Definir alturas (metros)
h_BS = 10;  % Estación base de antena
h_E = 1;    % Entorno efectivo de antena
h_UT = 1.5;  % Antena usuario
h_RIS = 10; % Altura de la RIS

% Definir alturas efectivas
h_BS_eff = h_BS - h_E;
h_UT_eff = h_UT - h_E;
h_RIS_eff = h_RIS - h_E;

% Diferencia de altura entre AP y UE (metros)
distanceVertical_AP_UE = h_BS - h_UT;
distanceVertical_RIS_UE = h_RIS - h_UT;

% Definir el espaciado de la antena (en número de longitudes de onda)
antennaSpacing = 1/2;

c = 3e8;

%Prepararar para guardar resultados
gainOverNoisedB = zeros(L,K);   % SNR en dB por enlace
R_AP_UE = zeros(N_AP,N_AP,L,K);       % Matriz de correlación
R_RIS_UE = zeros(N_RIS,N_RIS,S,K);      % Correlación RIS-UE
R_AP_RIS1 = zeros(N_AP,N_AP,L,S);      % Correlación AP-RIS 1
R_AP_RIS2 = zeros(N_RIS,N_RIS,L,S);     % Correlación AP-RIS 2
dist_AP_UE = zeros(L,K);        % Distancias AP-UE
dist_RIS_UE = zeros(S,K);       % Distancias RIS-UE
dist_AP_RIS = zeros(L,S);       % Distancias AP-RIS
maxdistances = 500;             
probLoS_AP_UE = zeros(L,K);     % Probabilidad de LoS entre AP y UE
probLoS_AP_RIS = zeros(L,S);    % Probabilidad de LoS entre AP y RIS
probLoS_RIS_UE = zeros(S,K);    % Probabilidad de LoS entre RIS y UE
pilotIndex = zeros(K);
D = zeros(L,K);                 % Atenuación del canal
betaLoS_AP_UE = zeros(L,1);
betaLoS_RIS_UE = zeros(S,1);
betaLoS_AP_RIS = zeros(L,1);
masterAPs = zeros(K,1);         % AP maestro por UE

%% Setups
    
    % Posiciones aleatorias de los APs con distribución uniforme
    APpositions = (rand(L,1) + 1i*rand(L,1)) * squareLength;                % Comparar con grid

    % Posiciones aleatorias de las RIS con distribución uniforme
    RISpositions = (rand(S,1) + 1i*rand(S,1)) * squareLength;               % Comparar con grid en punto intermedio entre APs
    
    % Inicializar posiciones de los usuarios (UEs)
    UEpositions = zeros(K,1);
        
    % Calcular ubicaciones alternativas de los APs con wraparound
    wrapHorizontal = repmat([-squareLength 0 squareLength],[3 1]);
    wrapVertical = wrapHorizontal';
    wrapLocations = wrapHorizontal(:)' + 1i*wrapVertical(:)';
    APpositionsWrapped = repmat(APpositions,[1 length(wrapLocations)]) + repmat(wrapLocations,[L 1]);
    
    % Matriz de correlación para shadowing
    shadowCorrMatrix_AP_UE = sigma_sf^2*ones(K,K);
    shadowAPrealizations_AP_UE = zeros(K,L);

    % Matriz de correlación para shadowing
    shadowCorrMatrix_RIS_UE = sigma_sf^2*ones(K,K);
    shadowAPrealizations_RIS_UE = zeros(K,S);

    % Matriz de correlación para shadowing
    shadowCorrMatrix_AP_RIS = sigma_sf^2*ones(S,S);
    shadowAPrealizations_AP_RIS = zeros(S,L);

    % Inicializar probabilidad de LoS
    if LoS==1
        probLoS_AP_UE=ones(L,K);
        probLoS_AP_RIS = ones(L,S);
        probLoS_RIS_UE = ones(S,K);
    elseif LoS == 0
        probLoS_AP_UE = zeros(L,K);
        probLoS_AP_RIS = zeros(L,S);
        probLoS_RIS_UE = zeros(S,K);
    end

    % Por cada usuario
    for k = 1:K
    
        % Posición aleatoria del usuario
        UEposition = (rand(1,1) + 1i*rand(1,1)) * squareLength;
        
        % Calcular distancias 3D con altura de APs
        [distanceAPstoUE, whichpos] = min(abs(APpositionsWrapped - repmat(UEposition, size(APpositionsWrapped))), [], 2);
        dist_AP_UE(:,k) = sqrt(distanceVertical_AP_UE^2 + distanceAPstoUE.^2);
        UEpositions(k) = UEposition;  %%NUEVO MIO
        dist_RIS_UE(:,k) = sqrt(distanceVertical_RIS_UE^2 + abs(UEpositions(k) - RISpositions).^2);
        % Modelo de path-loss UMi
        d_BP_eff = 4*h_BS_eff*h_UT_eff*((fc*1e9)./c);

        for l = 1:L
            d = dist_AP_UE(l,k);
            if d >= 10 && d <= d_BP_eff
                betaLoS_AP_UE(l) = 32.4 + 21 * log10(d) + 20 * log10(fc);
            elseif d > d_BP_eff && d <= 5000
                betaLoS_AP_UE(l) = 32.4 + 40 * log10(d) + 20 * log10(fc) - 9.5 * log10(d_BP_eff^2 + (h_BS - h_UT)^2);
            end
        end

        % Path-loss sin LoS
        PathNLoss_aux_AP_UE = 35.3 * log10(dist_AP_UE(:,k)) + 22.4 + 21.3 * log10(fc) - 0.3 * (h_UT - 1.5);
        betaNLoS_AP_UE = max(betaLoS_AP_UE,PathNLoss_aux_AP_UE);

        % Probabilidad aleatoria de LoS si LoS==2
        if LoS==2
            probLoS_AP_UE(:,k)=0;%(rand<((maxdistances-dist_AP_UE(:,k))./maxdistances));
            probLoS_RIS_UE(:,k) = (rand<((maxdistances-dist_RIS_UE(:,k))./maxdistances));
        end
    
        % Generación de shadowing
        if k-1 > 0
            shortestDistances = zeros(k-1,1);
            for i = 1:k-1
                shortestDistances(i) = min(abs(UEposition - UEpositions(i) + wrapLocations));
            end
            
            % Media y varianza condicional (teorema de estimación de Kay)
            newcolumn = sigma_sf^2 * 2.^(-shortestDistances / decorr);
            term1 = newcolumn' / shadowCorrMatrix_AP_UE(1:k-1,1:k-1);
            meanvalues = term1 * shadowAPrealizations_AP_UE(1:k-1,:);
            stdvalue = sqrt(sigma_sf^2 - term1 * newcolumn);

        else 
            % Primer usuario
            meanvalues = 0;
            stdvalue = sigma_sf;
            newcolumn = [];
        end 

        % Realización del shadowing
        shadowing_AP_UE = meanvalues + stdvalue * randn(1, L);

        % Inicializar ganancias del canal
        channelGaindB_AP_UE = zeros(L,1);
        gain_LoS_AP_UE = zeros(L,1);
        gain_NLoS_AP_UE = zeros(L,1);
    
        % Asignar ganancias según si hay LoS
        channelGaindB_AP_UE(probLoS_AP_UE(:,k)==1)=-betaLoS_AP_UE(probLoS_AP_UE(:,k)==1);
        channelGaindB_AP_UE(probLoS_AP_UE(:,k)==0)=-betaNLoS_AP_UE(probLoS_AP_UE(:,k)==0);
        channelGain_AP_UE = db2pow(channelGaindB_AP_UE) .* db2pow(shadowing_AP_UE') ./ db2pow(noiseVariancedBm); % Convert to linear scale and include shadowing and noise
    
        % Cálculo del factor de Rician
        ricianFactor_AP_UE = 10.^(1.3 - 0.003 * dist_AP_UE(:,k));
        
        gain_LoS_AP_UE(probLoS_AP_UE(:,k)==1) = sqrt(ricianFactor_AP_UE(probLoS_AP_UE(:,k)==1) ./ (ricianFactor_AP_UE(probLoS_AP_UE(:,k)==1) + 1)) .* channelGain_AP_UE(probLoS_AP_UE(:,k)==1);
        gain_NLoS_AP_UE(probLoS_AP_UE(:,k)==1) = sqrt(1 ./ (ricianFactor_AP_UE(probLoS_AP_UE(:,k)==1) + 1)) .* (channelGain_AP_UE(probLoS_AP_UE(:,k)==1));
        gain_NLoS_AP_UE(probLoS_AP_UE(:,k)==0)=channelGain_AP_UE(probLoS_AP_UE(:,k)==0); %note that probLoS is always one in the manuscript
    
        % Almacenar ganancia sobre ruido en dB
        gainOverNoisedB(:,k) = pow2db(channelGain_AP_UE);
    
        % Actualizar matrices de shadowing
        shadowCorrMatrix_AP_UE(1:k-1,k) = newcolumn;
        shadowCorrMatrix_AP_UE(k,1:k-1) = newcolumn';
        shadowAPrealizations_AP_UE(k,:) = shadowing_AP_UE;
    
        %UEpositions(k) = UEposition;    % Posición del usuario

        % Asignar AP maestro (con mejor canal)
        [~,master] = max(gainOverNoisedB(:,k));
        D(master,k) = 1;
        masterAPs(k) = master;
    
        % Asignar pilotos ortogonales
        if k <= tau_p
            pilotIndex(k) = k;
        else 
            % Elegir el piloto con menor interferencia
            pilotinterference = zeros(tau_p,1);

            for t = 1:tau_p
                pilotinterference(t) = sum(db2pow(gainOverNoisedB(master,pilotIndex(1:k-1) == t)));
            end

            [~,bestpilot] = min(pilotinterference);
            pilotIndex(k) = bestpilot;
        end
    
        % Para cada AP
        for l = 1:L

            % Ángulos horizontal y vertical al UE
            angletoUE_varphi = angle(UEpositions(k) - APpositionsWrapped(l, whichpos(l)));
            
            % Matriz de correlación espacial (modelo de dispersión local)
            if nargin > 5
                R_AP_UE(:,:,l,k) = gain_NLoS_AP_UE(l) * Rlocalscattering(N_AP, angletoUE_varphi, ASD_varphi, antennaSpacing);
            else
                R_AP_UE(:,:,l,k) = gain_NLoS_AP_UE(l) * eye(N_AP);
            end
    
            % Componente determinista LoS
            arrayResp_AP_UE = exp(1i * pi * (0:N_AP-1).' * sin(angletoUE_varphi));
            HMean_AP_UE(N_AP*(l-1)+1:N_AP*l,k) = sqrt(gain_LoS_AP_UE(l)) * arrayResp_AP_UE;
        end

        % ----- CALCULOS RIS-UE 

        for s = 1:S
            d = dist_RIS_UE(s,k);
            if d >= 10 && d <= d_BP_eff
                betaLoS_RIS_UE(s) = 32.4 + 21 * log10(d) + 20 * log10(fc);
            elseif d > d_BP_eff && d <= 5000
                betaLoS_RIS_UE(s) = 32.4 + 40 * log10(d) + 20 * log10(fc) - 9.5 * log10(d_BP_eff^2 + (h_RIS - h_UT)^2);
            end
        end

        % Path-loss sin LoS
        PathNLoss_aux_RIS_UE = 35.3 * log10(dist_RIS_UE(:,k)) + 22.4 + 21.3 * log10(fc) - 0.3 * (h_UT - 1.5);
        betaNLoS_RIS_UE = max(betaLoS_RIS_UE,PathNLoss_aux_RIS_UE);

        % Generación de shadowing
        if k-1 > 0
            shortestDistances = zeros(k-1,1);
            for i = 1:k-1
                shortestDistances(i) = min(abs(UEposition - UEpositions(i)));
            end
            
            % Media y varianza condicional (teorema de estimación de Kay)
            newcolumn = sigma_sf^2 * 2.^(-shortestDistances / decorr);
            term1 = newcolumn' / shadowCorrMatrix_RIS_UE(1:k-1,1:k-1);
            meanvalues = term1 * shadowAPrealizations_RIS_UE(1:k-1,:);
            stdvalue = sqrt(sigma_sf^2 - term1 * newcolumn);

        else 
            % Primer usuario
            meanvalues = 0;
            stdvalue = sigma_sf;
            newcolumn = [];
        end 

        % Realización del shadowing
        shadowing_RIS_UE = meanvalues + stdvalue * randn(1, S);

         % Inicializar ganancias del canal
        channelGaindB_RIS_UE = zeros(S,1);
        gain_LoS_RIS_UE = zeros(S,1);
        gain_NLoS_RIS_UE = zeros(S,1);
    
        % Asignar ganancias según si hay LoS
        channelGaindB_RIS_UE(probLoS_RIS_UE(:,k)==1)=-betaLoS_RIS_UE(probLoS_RIS_UE(:,k)==1);
        channelGaindB_RIS_UE(probLoS_RIS_UE(:,k)==0)=-betaNLoS_RIS_UE(probLoS_RIS_UE(:,k)==0);
        channelGain_RIS_UE = db2pow(channelGaindB_RIS_UE) .* db2pow(shadowing_RIS_UE') ./ db2pow(noiseVariancedBm); % Convert to linear scale and include shadowing and noise
    
        % Cálculo del factor de Rician
        ricianFactor_RIS_UE = 10.^(1.3 - 0.003 * dist_RIS_UE(:,k));
        
        gain_LoS_RIS_UE(probLoS_RIS_UE(:,k)==1) = sqrt(ricianFactor_RIS_UE(probLoS_RIS_UE(:,k)==1) ./ (ricianFactor_RIS_UE(probLoS_RIS_UE(:,k)==1) + 1)) .* channelGain_RIS_UE(probLoS_RIS_UE(:,k)==1);
        gain_NLoS_RIS_UE(probLoS_RIS_UE(:,k)==1) = sqrt(1 ./ (ricianFactor_RIS_UE(probLoS_RIS_UE(:,k)==1) + 1)) .* (channelGain_RIS_UE(probLoS_RIS_UE(:,k)==1));
        gain_NLoS_RIS_UE(probLoS_RIS_UE(:,k)==0)=channelGain_RIS_UE(probLoS_RIS_UE(:,k)==0); 
    
         % Actualizar matrices de shadowing
        shadowCorrMatrix_RIS_UE(1:k-1,k) = newcolumn;
        shadowCorrMatrix_RIS_UE(k,1:k-1) = newcolumn';
        shadowAPrealizations_RIS_UE(k,:) = shadowing_RIS_UE;
    
        UEpositions(k) = UEposition;    % Actualizo posición del usuario

        % Para cada RIS
        for s = 1:S
            %% PREGUNTAR CÓMO ES EL ANGLETOUE_VARPHI
            % Ángulos horizontal y vertical al UE
            angletoUE_varphi = angle(UEpositions(k) - RISpositions(s));
            
            % Matriz de correlación espacial (modelo de dispersión local)
            if nargin > 5
                R_RIS_UE(:,:,s,k) = gain_NLoS_RIS_UE(s) * Rlocalscattering(N_RIS, angletoUE_varphi, ASD_varphi, antennaSpacing);
            else
                R_RIS_UE(:,:,s,k) = gain_NLoS_RIS_UE(s) * eye(N_RIS);
            end
    
            % Componente determinista LoS
            arrayResp_RIS_UE = exp(1i * pi * (0:N_RIS-1).' * sin(angletoUE_varphi));
            HMean_RIS_UE(N_RIS*(s-1)+1:N_RIS*s,k) = sqrt(gain_LoS_RIS_UE(s)) * arrayResp_RIS_UE;
  
        end
    end

    %% ------ DISTANCIAS  AP-RIS

    for s = 1:S

        % Distancia 2D AP - RIS
        dist_AP_RIS(:,s) = abs(APpositions - RISpositions(s));
        % Modelo de path-loss UMi
        d_BP_eff = 4*h_RIS_eff*h_BS_eff*((fc*1e9)./c);

        % Path-loss LoS
        for l = 1:L
            d = dist_AP_RIS(l,s);
            if d >= 10 && d <= d_BP_eff
                betaLoS_AP_RIS(l) = 32.4 + 21 * log10(d) + 20 * log10(fc);
            elseif d > d_BP_eff && d <= 5000
                betaLoS_AP_RIS(l) = 32.4 + 40 * log10(d) + 20 * log10(fc) - 9.5 * log10(d_BP_eff^2 + (h_BS - h_RIS)^2);
            end
        end
        % Path-loss sin LoS
        PathNLoss_aux_AP_RIS = 35.3 * log10(dist_AP_RIS(:,s)) + 22.4 + 21.3 * log10(fc) - 0.3 * (h_RIS - 1.5);
        betaNLoS_AP_RIS = max(betaLoS_AP_RIS,PathNLoss_aux_AP_RIS);

        % Probabilidad aleatoria de LoS si LoS==2
        if LoS==2
            probLoS_AP_RIS(:,s)=1;%(rand<((maxdistances-dist_AP_RIS(:,s))./maxdistances));
        end

         % Generación de shadowing 
        if s-1 > 0
            shortestDistances = zeros(s-1,1);
            for i = 1:s-1
                shortestDistances(i) = min(abs(RISpositions(s) - RISpositions(i)));
            end
            
            % Media y varianza condicional (teorema de estimación de Kay)
            newcolumn = sigma_sf^2 * 2.^(-shortestDistances / decorr);
            term1 = newcolumn' / shadowCorrMatrix_AP_RIS(1:s-1,1:s-1);
            meanvalues = term1 * shadowAPrealizations_AP_RIS(1:s-1,:);
            stdvalue = sqrt(sigma_sf^2 - term1 * newcolumn);

        else 
            % Primer usuario
            meanvalues = 0;
            stdvalue = sigma_sf;
            newcolumn = [];
        end 

        % Realización del shadowing
        shadowing_AP_RIS = meanvalues + stdvalue * randn(1, L);

        % Inicializar ganancias del canal
        channelGaindB_AP_RIS = zeros(L,1);
        gain_LoS_AP_RIS = zeros(L,1);
        gain_NLoS_AP_RIS = zeros(L,1);
        
        % Asignar ganancias según si hay LoS
        channelGaindB_AP_RIS(probLoS_AP_RIS(:,s)==1)=-betaLoS_AP_RIS(probLoS_AP_RIS(:,s)==1);
        channelGaindB_AP_RIS(probLoS_AP_RIS(:,s)==0)=-betaNLoS_AP_RIS(probLoS_AP_RIS(:,s)==0);
        channelGain_AP_RIS = db2pow(channelGaindB_AP_RIS) .* db2pow(shadowing_AP_RIS') ./ db2pow(noiseVariancedBm); 
    
        % Rician factor
        ricianFactor_AP_RIS = 10.^(1.3 - 0.003 * dist_AP_RIS(:,s));
        gain_LoS_AP_RIS(probLoS_AP_RIS(:,s)==1) = sqrt(ricianFactor_AP_RIS(probLoS_AP_RIS(:,s)==1) ./ (ricianFactor_AP_RIS(probLoS_AP_RIS(:,s)==1) + 1)) .* channelGain_AP_RIS(probLoS_AP_RIS(:,s)==1);
        gain_NLoS_AP_RIS(probLoS_AP_RIS(:,s)==1) = sqrt(1 ./ (ricianFactor_AP_RIS(probLoS_AP_RIS(:,s)==1) + 1)) .* (channelGain_AP_RIS(probLoS_AP_RIS(:,s)==1));
        gain_NLoS_AP_RIS(probLoS_AP_RIS(:,s)==0)=channelGain_AP_RIS(probLoS_AP_RIS(:,s)==0); %note that probLoS is always one in the manuscript
        
        % Actualizar matrices de shadowing
        shadowCorrMatrix_AP_RIS(1:s-1,s) = newcolumn;
        shadowCorrMatrix_AP_RIS(s,1:s-1) = newcolumn';
        shadowAPrealizations_AP_RIS(s,:) = shadowing_AP_RIS;

        for l = 1:L

            % Correlación espacial
            angle_varphi = angle(RISpositions(s) - APpositions(l));
            
            if nargin > 5
                R_AP_RIS1(:,:,l,s) = gain_NLoS_AP_RIS(l) * Rlocalscattering(N_AP, angle_varphi, ASD_varphi, antennaSpacing);
                R_AP_RIS2(:,:,l,s) = gain_NLoS_AP_RIS(l) * Rlocalscattering(N_RIS, angle_varphi, ASD_varphi, antennaSpacing);
            else
                R_AP_RIS1(:,:,l,s) = gain_NLoS_AP_RIS(l) * eye(N_AP);
                R_AP_RIS2(:,:,l,s) = gain_NLoS_AP_RIS(l) * eye(N_RIS);
            end
        
            % Componente determinista
            arrayResp_AP = exp(1i * pi * (0:N_AP-1).' * sin(angle_varphi));
            arrayResp_RIS = exp(1i * pi * (0:N_RIS-1).' * sin(angle_varphi));
            HMean_AP_RIS(N_AP*(l-1)+1:N_AP*l,N_RIS*(s-1)+1:N_RIS*s) = sqrt(gain_LoS_AP_RIS(l)) * arrayResp_AP * arrayResp_RIS.';
        end 
    end   

    % Cada AP sirve al UE con mejor canal para cada piloto
    for l = 1:L
        
        for t = 1:tau_p
            
            pilotUEs = find(t==pilotIndex(:));
            [~,UEindex] = max(gainOverNoisedB(l,pilotUEs));
            D(l,pilotUEs(UEindex)) = 1;
           
        end
        
    end
        
    


