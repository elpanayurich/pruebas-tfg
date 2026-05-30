function [HMean_X_Y, gainOverNoisedB, probLoS_X_Y, shadowCorrMatrix_X_Y, shadowAPrealizations_X_Y, R_X_Y_1, R_X_Y_2] = calculateHmean(X_Y, n, M, N_AP, N_RIS,dist_X_Y, betaLos_X_Y, fc, d_BP_eff, h_1, h_2, LoS, probLoS_X_Y, UEposition, UEpositions, RISpositions, APpositions, wrapLocations, APpositionsWrapped, whichpos, sigma_sf, decorr, shadowCorrMatrix_X_Y, shadowAPrealizations_X_Y, noiseVariancedBm, prenargin, R_X_Y_1, R_X_Y_2, HMean_X_Y, ASD_varphi, antennaSpacing, h_X, X)

for m = 1:M
    d = dist_X_Y(m,n);
    if d >= 10 && d <= d_BP_eff
        betaLos_X_Y(m) = 32.4 + 21 * log10(d) + 20 * log10(fc);
    elseif d > d_BP_eff && d <= 5000
        betaLos_X_Y(m) = 32.4 + 40 * log10(d) + 20 * log10(fc) - 9.5 * log10(d_BP_eff^2 + (h_1 - h_2)^2);
    end
end

% Path-loss sin LoS
PathNLoss_X_Y = 35.3 * log10(dist_X_Y(:,n)) + 22.4 + 21.3 * log10(fc) - 0.3 * (h_2 - 1.5);
betaNLoS_X_Y = max(betaLos_X_Y,PathNLoss_X_Y);

% Probabilidad aleatoria de LoS si LoS==2
if LoS==2
    for i=1:X
        if h_X > 8
            C = ((h_X - 8)/10)^1.5;
        else
            C = 0;
        end
        if dist_X_Y > 18
            term1 = (18./dist_X_Y(:,i)) + exp(-dist_X_Y(:,i)./63) .* (1 - (18./dist_X_Y(:,i)));
            term2 = 1 + C * (5/4) * ((dist_X_Y(:,i)./100).^3) .* exp(-dist_X_Y(:,i)./150);
            probLoS_X_Y(:,i) = term1 .* term2;
        else
            probLoS_X_Y(:,i) = 1;
        end
    end
    [rows, columns] = size(probLoS_X_Y);
    for i = 1:rows
        for j = 1:columns
            rand_aux = rand;
            if probLoS_X_Y(i,j) < rand_aux
                probLoS_X_Y(i,j) = 0;
            else
                probLoS_X_Y(i,j) = 1;
            end
        end
    end
end

% Generación de shadowing
if n-1 > 0
    shortestDistances = zeros(n-1,1);
    if X_Y == "AP_UE"
        for i = 1:n-1
            shortestDistances(i) = min(abs(UEposition - UEpositions(i) + wrapLocations));
        end
    elseif X_Y == "RIS_UE"
        for i = 1:n-1
            shortestDistances(i) = min(abs(UEposition - UEpositions(i)));
        end
    elseif X_Y == "AP_RIS"
        for i = 1:n-1
            shortestDistances(i) = min(abs(RISpositions(n) - RISpositions(i)));
        end
    end
    
    % Media y varianza condicional (teorema de estimación de Kay)
    newcolumn = sigma_sf^2 * 2.^(-shortestDistances / decorr);
    term1 = newcolumn' / shadowCorrMatrix_X_Y(1:n-1,1:n-1);
    meanvalues = term1 * shadowAPrealizations_X_Y(1:n-1,:);
    stdvalue = sqrt(sigma_sf^2 - term1 * newcolumn);
    
else
    % Primer usuario
    meanvalues = 0;
    stdvalue = sigma_sf;
    newcolumn = [];
end

% Realización del shadowing
shadowing_X_Y = meanvalues + stdvalue * randn(1, M);

% Inicializar ganancias del canal
channelGaindB_X_Y = zeros(M,1);
gain_LoS_X_Y = zeros(M,1);
gain_NLoS_X_Y = zeros(M,1);

% Asignar ganancias según si hay LoS
channelGaindB_X_Y(probLoS_X_Y(:,n)==1)=-betaLos_X_Y(probLoS_X_Y(:,n)==1);
channelGaindB_X_Y(probLoS_X_Y(:,n)==0)=-betaNLoS_X_Y(probLoS_X_Y(:,n)==0);
channelGain_X_Y = db2pow(channelGaindB_X_Y) .* db2pow(shadowing_X_Y') ./ db2pow(noiseVariancedBm); % Convert to linear scale and include shadowing and noise

% Cálculo del factor de Rician
ricianFactor_X_Y = 10.^(1.3 - 0.003 * dist_X_Y(:,n));
gain_LoS_X_Y(probLoS_X_Y(:,n)==1) = sqrt(ricianFactor_X_Y(probLoS_X_Y(:,n)==1) ./ (ricianFactor_X_Y(probLoS_X_Y(:,n)==1) + 1)) .* channelGain_X_Y(probLoS_X_Y(:,n)==1);
gain_NLoS_X_Y(probLoS_X_Y(:,n)==1) = sqrt(1 ./ (ricianFactor_X_Y(probLoS_X_Y(:,n)==1) + 1)) .* (channelGain_X_Y(probLoS_X_Y(:,n)==1));
gain_NLoS_X_Y(probLoS_X_Y(:,n)==0) = channelGain_X_Y(probLoS_X_Y(:,n)==0); %note that probLoS is always one in the manuscript

% Almacenar ganancia sobre ruido en dB
if X_Y == "AP_UE"
    gainOverNoisedB(:,n) = pow2db(channelGain_X_Y);
end

% Actualizar matrices de shadowing
shadowCorrMatrix_X_Y(1:n-1,n) = newcolumn;
shadowCorrMatrix_X_Y(n,1:n-1) = newcolumn';
shadowAPrealizations_X_Y(n,:) = shadowing_X_Y;
for  m = 1:M
    
    % Ángulos horizontal y vertical
    if X_Y == "AP_UE"
        angletoUE_varphi = angle(UEpositions(n) - APpositionsWrapped(m, whichpos(m)));
    elseif X_Y == "RIS_UE"
        angletoUE_varphi = angle(UEpositions(n) - RISpositions(m));
    elseif X_Y == "AP_RIS"
        angle_varphi = angle(RISpositions(n) - APpositions(m));
    end
    
    if X_Y == "AP_UE"
        % Matriz de correlación espacial (modelo de dispersión local)
        if prenargin > 6
            R_X_Y_1(:,:,m,n) = gain_NLoS_X_Y(m) * Rlocalscattering(N_AP, angletoUE_varphi, ASD_varphi, antennaSpacing);
            R_X_Y_2 = NaN;
        else
            R_X_Y_1(:,:,m,n) = gain_NLoS_X_Y(m) * eye(N_AP);
            R_X_Y_2 = NaN;
        end
        
        % Componente determinista LoS
        arrayResp_X_Y = exp(1i * pi * (0:N_AP-1).' * sin(angletoUE_varphi));
        HMean_X_Y(N_AP*(m-1)+1:N_AP*m,n) = sqrt(gain_LoS_X_Y(m)) * arrayResp_X_Y;
        
    elseif X_Y == "RIS_UE"
        if prenargin > 6
            R_X_Y_1(:,:,m,n) = gain_NLoS_X_Y(m) * Rlocalscattering(N_RIS, angletoUE_varphi, ASD_varphi, antennaSpacing);
            R_X_Y_2 = NaN;
        else
            R_X_Y_1(:,:,m,n) = gain_NLoS_X_Y(m) * eye(N_RIS);
            R_X_Y_2 = NaN;
        end
        
        % Componente determinista LoS
        arrayResp_X_Y = exp(1i * pi * (0:N_RIS-1).' * sin(angletoUE_varphi));
        HMean_X_Y(N_RIS*(m-1)+1:N_RIS*m,n) = sqrt(gain_LoS_X_Y(m)) * arrayResp_X_Y;
        
    elseif X_Y == "AP_RIS"
        % Matriz de correlación espacial (modelo de dispersión local)
        if prenargin > 6
            R_X_Y_1(:,:,m,n) = gain_NLoS_X_Y(m) * Rlocalscattering(N_AP, angle_varphi, ASD_varphi, antennaSpacing);
            R_X_Y_2(:,:,m,n) = gain_NLoS_X_Y(m) * Rlocalscattering(N_RIS, angle_varphi, ASD_varphi, antennaSpacing);
        else
            R_X_Y_1(:,:,m,n) = gain_NLoS_X_Y(m) * eye(N_AP);
            R_X_Y_2(:,:,m,n) = gain_NLoS_X_Y(m) * eye(N_RIS);
        end
        
        % Componente determinista
        arrayResp_X = exp(1i * pi * (0:N_AP-1).' * sin(angle_varphi)) / sqrt(N_AP);
        arrayResp_Y = exp(1i * pi * (0:N_RIS-1).' * sin(angle_varphi)) / sqrt(N_RIS);
        HMean_X_Y(N_AP*(m-1)+1:N_AP*m,N_RIS*(n-1)+1:N_RIS*n) = sqrt(gain_NLoS_X_Y(m)) * arrayResp_X * arrayResp_Y.';
    end
end

if X_Y == "RIS_UE" || X_Y == "AP_RIS"
    gainOverNoisedB = NaN;
end
end