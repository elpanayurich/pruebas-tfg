function [R_AP_UE,R_AP_RIS1,R_AP_RIS2,R_RIS_UE,pilotIndex,D,HMean_AP_UE, HMean_AP_RIS, HMean_RIS_UE, probLoS_AP_UE, probLoS_RIS_UE] = setup(L,K,N_AP,N_RIS,tau_p,seed,ASD_varphi,LoS,fc,S)
%% Definir escenario
HMean_AP_UE = zeros(N_AP*L,K);          % Canal LoS AP-UE
HMean_RIS_UE = zeros(N_RIS*S,K);        % Canal LoS RIS-UE
HMean_AP_RIS = zeros(N_AP*L,N_RIS*S);   % Canal LoS AP-RIS


%Establecer el número de semilla si se especifica distinto de cero
if (nargin>5)&&(seed>0)
    rng(seed)
end

squareLength = 1000;    %Tamaño del área de cobertura
center_grid_factor = 0.7;   %Factor de rango de superficie donde puede haber un AP en el grid, entre 0 y 1
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

% Generar las posiciones de los APs, UEs y RIS
[APpositions, RISpositions, UEpositions, wrapLocations, APpositionsWrapped] = positions_setup(L, K, squareLength, center_grid_factor);
%draw_setup(APpositions, RISpositions, UEpositions);

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
    probLoS_AP_UE = ones(L,K);
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
    UEposition = UEpositions(k);
    
    % Calcular distancias 3D con altura de APs
    [distanceAPstoUE, whichpos] = min(abs(APpositionsWrapped - repmat(UEposition, size(APpositionsWrapped))), [], 2);
    dist_AP_UE(:,k) = sqrt(distanceVertical_AP_UE^2 + distanceAPstoUE.^2);
    dist_RIS_UE(:,k) = sqrt(distanceVertical_RIS_UE^2 + abs(UEposition - RISpositions).^2);
    % Modelo de path-loss UMi
    d_BP_eff = 4*h_BS_eff*h_UT_eff*((fc*1e9)./c);
    
    X_Y = "AP_UE";
    [HMean_AP_UE, gainOverNoisedB, probLoS_AP_UE, shadowCorrMatrix_AP_UE, shadowAPrealizations_AP_UE, R_AP_UE, ~] = calculateHmean(X_Y, k, L, N_AP, N_RIS, dist_AP_UE, betaLoS_AP_UE, fc, d_BP_eff, h_BS, h_UT, LoS, probLoS_AP_UE, UEposition, UEpositions, RISpositions, APpositions, wrapLocations, APpositionsWrapped, whichpos, sigma_sf, decorr, shadowCorrMatrix_AP_UE, shadowAPrealizations_AP_UE, noiseVariancedBm, nargin, R_AP_UE, 0, HMean_AP_UE, ASD_varphi, antennaSpacing, h_UT, K);
    
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
    
    % ----- CALCULOS RIS-UE
    X_Y = "RIS_UE";
    [HMean_RIS_UE, ~, probLoS_RIS_UE, shadowCorrMatrix_RIS_UE, shadowAPrealizations_RIS_UE, R_RIS_UE, ~] = calculateHmean(X_Y, k, S, N_AP, N_RIS, dist_RIS_UE, betaLoS_RIS_UE, fc, d_BP_eff, h_RIS, h_UT, LoS, probLoS_RIS_UE, UEposition, UEpositions, RISpositions, APpositions, wrapLocations, APpositionsWrapped, whichpos, sigma_sf, decorr, shadowCorrMatrix_RIS_UE, shadowAPrealizations_RIS_UE, noiseVariancedBm, nargin, R_RIS_UE, 0, HMean_RIS_UE, ASD_varphi, antennaSpacing, h_UT, K);
    
end

%% ------ DISTANCIAS  AP-RIS

for s = 1:S
    dist_AP_RIS(:,s) = abs(APpositions - RISpositions(s));
    % Modelo de path-loss UMi
    d_BP_eff = 4*h_RIS_eff*h_BS_eff*((fc*1e9)./c);
    
    X_Y = "AP_RIS";
    [HMean_AP_RIS, ~, probLoS_AP_RIS, shadowCorrMatrix_AP_RIS, shadowAPrealizations_AP_RIS, R_AP_RIS1, R_AP_RIS2] = calculateHmean(X_Y, s, L, N_AP, N_RIS, dist_AP_RIS, betaLoS_AP_RIS, fc, d_BP_eff, h_BS, h_RIS, LoS, probLoS_AP_RIS, UEposition, UEpositions, RISpositions, APpositions, wrapLocations, APpositionsWrapped, whichpos, sigma_sf, decorr, shadowCorrMatrix_AP_RIS, shadowAPrealizations_AP_RIS, noiseVariancedBm, nargin, R_AP_RIS1, R_AP_RIS2, HMean_AP_RIS, ASD_varphi, antennaSpacing, h_RIS, S);
    
end

% Cada AP sirve al UE con mejor canal para cada piloto
for l = 1:L
    
    for t = 1:tau_p
        
        pilotUEs = find(t==pilotIndex(:));
        [~,UEindex] = max(gainOverNoisedB(l,pilotUEs));
        D(l,pilotUEs(UEindex)) = 1;
        
    end
    
end
end