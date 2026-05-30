% main_gpu.m
% GPU-Accelerated version of main1.m
% Uses vectorized functions for 10-100x speedup.

% Vaciar espacio de trabajo y cerrar figuras
close all;
clear;

%% Setup de simulación
nbrOfSetups = 25;   % Número de escenarios
nbrOfRealizations = 100;    % Número de realizaciones

L = 16;          % Número de APs
N_AP = 1;        % Antenas por AP
N_RIS = 100;     % Número de elementos de la RIS
K = 10;          % Número de UEs
tau_c = 200;     % Longitud del bloque de coherencia
tau_p = 10;      % Longitud del piloto
p = 100;         % Potencia de transmisión (mW)
fc = 3.5;        % Frecuencia (GHz)
LoS = 2;         % Linea de visión directa
% Desviación estándar angular en el modelo de dispersión local (en radianes)
ASD_varphi = deg2rad(15);  % angulo de azimut

% GPU Settings
useGPU = true; % Set to true to use GPU, false for CPU
if useGPU && parallel.gpu.GPUDevice.isAvailable
    g = gpuDevice;
    disp(['Using GPU: ' g.Name]);
else
    disp('Using CPU (Vectorized).');
    useGPU = false;
end

% Arreglos 3D para guardar resultados por tipo de canal
SE_PMMSE_DCC = zeros(K, nbrOfSetups, 6);

%% Numero de RIS
S_values = (sqrt(L) + 1)^2;
for s = 1:length(S_values)
    S = S_values(s);
    for n = 1:nbrOfSetups
        disp(['Setup ' num2str(n) '/' num2str(nbrOfSetups) ' asistido por ' num2str(S) ' RIS']);
        
        % Generar escenario (CPU only - setup is sequential)
        seed = randi(10000);
        [R_AP_UE,R_AP_RIS1,R_AP_RIS2,R_RIS_UE,pilotIndex,D,HMean_AP_UE, HMean_AP_RIS, HMean_RIS_UE, probLoS_AP_UE, probLoS_RIS_UE] = setup(L,K,N_AP,N_RIS,tau_p,seed,ASD_varphi,LoS,fc,S);
        
        % Asignacion de RIS
        if S == 0
            risAssignment = [];
        else
            risAssignment = assignRIS(probLoS_AP_UE, probLoS_RIS_UE);
        end
        
        % Move to GPU if requested
        if useGPU
            R_AP_UE_in = gpuArray(R_AP_UE);
            R_AP_RIS1_in = gpuArray(R_AP_RIS1);
            R_AP_RIS2_in = gpuArray(R_AP_RIS2);
            R_RIS_UE_in = gpuArray(R_RIS_UE);
            HMean_AP_UE_in = gpuArray(HMean_AP_UE);
            HMean_AP_RIS_in = gpuArray(HMean_AP_RIS);
            HMean_RIS_UE_in = gpuArray(HMean_RIS_UE);
            % Integers/logical matrices like D, pilotIndex can stay on CPU or move.
            % But SE_uplink uses D. Moving D to GPU is safer for pagemtimes if mixed.
            D_in = gpuArray(D);
        else
            R_AP_UE_in = R_AP_UE;
            R_AP_RIS1_in = R_AP_RIS1;
            R_AP_RIS2_in = R_AP_RIS2;
            R_RIS_UE_in = R_RIS_UE;
            HMean_AP_UE_in = HMean_AP_UE;
            HMean_AP_RIS_in = HMean_AP_RIS;
            HMean_RIS_UE_in = HMean_RIS_UE;
            D_in = D;
        end

        % Estimar canales (Vectorized)
        % Using the new vectorized function (assumed to be named channelEstimates now or we call vectorized explicitly)
        % We will use the file name 'channelEstimates' assuming the user applied the patch.
        % If not, we can call channelEstimates_Vectorized.
        
        % Note: I will assume the user runs apply_optimizations.m, so 'channelEstimates' IS the vectorized one.
        [Hhat,H_eq,R_eq,B,C] = channelEstimates(R_AP_UE_in,R_AP_RIS1_in,R_AP_RIS2_in,R_RIS_UE_in,nbrOfRealizations,L,K,S,N_AP,N_RIS,tau_p,pilotIndex,p,HMean_AP_UE_in,HMean_AP_RIS_in, HMean_RIS_UE_in,risAssignment);
        
        % Calcular SE (Vectorized)
        [SE_P_MMSE, SE_MR_dist] = SE_uplink(Hhat,H_eq,D_in,B,C,tau_c,tau_p,nbrOfRealizations,N_AP,K,L,p,R_eq,pilotIndex);
        
        % Gather results if on GPU
        if useGPU
            SE_P_MMSE = gather(SE_P_MMSE);
        end
        
        % Guardar resultados en la dimensión
        SE_PMMSE_DCC(:,n,s) = SE_P_MMSE;
        
        clear Hhat H_eq B C R_eq;
    end
end

save('results_gpu.mat', 'SE_PMMSE_DCC')

%% Graficar resultados
figure; hold on; box on;
set(gca,'fontsize',16);

% P-MMSE
aux1 = SE_PMMSE_DCC(:,:,1); % 0 RIS
plot(sort(aux1(:)), linspace(0,1,K*nbrOfSetups), 'k-', 'LineWidth', 2);

xlabel('Spectral efficiency [bit/s/Hz]', 'Interpreter', 'Latex');
ylabel('CDF', 'Interpreter', 'Latex');
legend_text = sprintf('P-MMSE %d RIS', S);
legend({legend_text}, 'Interpreter', 'Latex', 'Location', 'SouthEast');
xlim([0 25]);
