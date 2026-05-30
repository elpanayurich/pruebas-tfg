% Vaciar espacio de trabajo y cerrar figuras
close all;
clear;

%% Setup de simulación
nbrOfSetups = 1;   % Número de escenarios
nbrOfRealizations = 100;    % Número de realizaciones

L = 16;          % Número de APs
N_AP = 1;        % Antenas por AP
N_RIS = 100;     % Número de elementos de la RIS
K = 10;          % Número de UEs
tau_c = 200;     % Longitud del bloque de coherencia
tau_p = 10;      % Longitud del piloto
p = 100;         % Potencia de transmisión (mW)
fc = 3.5;        % Frecuencia (GHz)
LoS = 1;         % Linea de visión directa
% Desviación estándar angular en el modelo de dispersión local (en radianes)
ASD_varphi = deg2rad(15);  % angulo de azimut

% Arreglos 3D para guardar resultados por tipo de canal
SE_PMMSE_DCC = zeros(K, nbrOfSetups, 6);
%SE_MR_DIST   = zeros(K, nbrOfSetups, 6);

%% Numero de RIS
%S_values = [0,5,10,20,50,100];
S_values = (sqrt(L) + 1)^2;
for s = 1:length(S_values)
    S = S_values(s);
    for n = 1:nbrOfSetups
        disp(['Setup ' num2str(n) '/' num2str(nbrOfSetups) ' asistido por ' num2str(S) ' RIS']);
        
        % Generar escenario
        seed = randi(10000);
        [R_AP_UE,R_AP_RIS1,R_AP_RIS2,R_RIS_UE,pilotIndex,D,HMean_AP_UE, HMean_AP_RIS, HMean_RIS_UE, probLoS_AP_UE, probLoS_RIS_UE] = setup(L,K,N_AP,N_RIS,tau_p,seed,ASD_varphi,LoS,fc,S);
        
        % Asignacion de RIS
        if S == 0
            risAssignment = [];
        else
            risAssignment = assignRIS(probLoS_AP_UE, probLoS_RIS_UE);
        end
        %Asignar todos los usuarios a todas las RISs
        %  for aux = 1:S
        %     risAssignment{aux} = 1:K;     % Asignar todos los usuarios a cada RIS
        %     risAssignment{aux} = randi(K); % Asignación un usuario por RIS aleatorio
        %  end
        % Estimar canales
        [Hhat,H_eq,R_eq,B,C] = channelEstimates(R_AP_UE,R_AP_RIS1,R_AP_RIS2,R_RIS_UE,nbrOfRealizations,L,K,S,N_AP,N_RIS,tau_p,pilotIndex,p,HMean_AP_UE,HMean_AP_RIS, HMean_RIS_UE,risAssignment);
        
        % Calcular SE
        [SE_P_MMSE, SE_MR_dist] = SE_uplink(Hhat,H_eq,D,B,C,tau_c,tau_p,nbrOfRealizations,N_AP,K,L,p,R_eq,pilotIndex);
        
        
        % Guardar resultados en la dimensión
        SE_PMMSE_DCC(:,n,s) = SE_P_MMSE;
        %sum(SE_P_MMSE)
        %SE_MR_DIST(:,n,s)  = SE_MR_dist;
        
        clear Hhat H_eq B C R_eq;
    end
end

save('results1')

%% Graficar resultados
figure; hold on; box on;
set(gca,'fontsize',16);

% P-MMSE
aux1 = SE_PMMSE_DCC(:,:,1); % 0 RIS
aux2 = SE_PMMSE_DCC(:,:,2); % 5 RIS
aux3 = SE_PMMSE_DCC(:,:,3); % 10 RIS
aux4 = SE_PMMSE_DCC(:,:,4); % 20 RIS
aux5 = SE_PMMSE_DCC(:,:,5); % 50 RIS
aux6 = SE_PMMSE_DCC(:,:,6); % 100 RIS

plot(sort(aux1(:)), linspace(0,1,K*nbrOfSetups), 'k-', 'LineWidth', 2);
plot(sort(aux2(:)), linspace(0,1,K*nbrOfSetups), 'r-',  'LineWidth', 2);
plot(sort(aux3(:)), linspace(0,1,K*nbrOfSetups), 'g-', 'LineWidth', 2);
plot(sort(aux4(:)), linspace(0,1,K*nbrOfSetups), 'b-', 'LineWidth', 2);
plot(sort(aux5(:)), linspace(0,1,K*nbrOfSetups), 'm-',  'LineWidth', 2);
plot(sort(aux6(:)), linspace(0,1,K*nbrOfSetups), 'y-', 'LineWidth', 2);

% Ejes y leyenda
xlabel('Spectral efficiency [bit/s/Hz]', 'Interpreter', 'Latex');
ylabel('CDF', 'Interpreter', 'Latex');
legend({'P-MMSE 0 RIS', 'P-MMSE 5 RIS', 'P-MMSE 10 RIS', 'P-MMSE 20 RIS', 'P-MMSE 50 RIS', 'P-MMSE 100 RIS'}, 'Interpreter', 'Latex', 'Location', 'SouthEast');
xlim([0 25]);