% Vaciar espacio de trabajo y cerrar figuras
%close all;
%clear;

%% Setup de simulación
nbrOfSetups = 12;              % Número de escenarios
nbrOfRealizations = 100;       % Número de realizaciones

preloaded_positions = false;   % Declarar si tenemos precargada la posicion o no

L = 16;                        % Número de APs (Ex: 9, 16, 25...)
N_AP = 1;                      % Antenas por AP
N_RIS = 64;                    % Número de elementos de la RIS
K = 15;                        % Número de UEs
tau_c = 10000;                 % Longitud del bloque de coherencia
tau_p = K;                     % Setting no waste for the prelog factor
p = 100;                       % Potencia de transmisión (mW)
fc = 3.5;                      % Frecuencia (GHz)
LoS = 2;                       % Linea de visión directa
h_BS = 10;                     % Estación base de antena
h_UT = 1.5;                    % Antena usuario
h_RIS = 10;                    % Altura de la RIS
squareLength = 1000;           % Tamaño del área de cobertura
center_grid_factor = 0.5;      % Factor de rango de superficie donde puede haber un AP en el grid, entre 0 y 1
user_percentage = 0.1;         % El radio de la RIS dependerá del porcentaje de usuarios al cual queremos dar mejor calidad de señal

% Desviación estándar angular en el modelo de dispersión local (en radianes)
ASD_varphi = deg2rad(15);  % angulo de azimut

% Arreglos 3D para guardar resultados por tipo de canal
SE_PMMSE_DCC = zeros(K, nbrOfSetups, 6);
%SE_MR_DIST   = zeros(K, nbrOfSetups, 6);

% Crear directorios pertinentes
current_dir = pwd;
positions_dir = fullfile(current_dir, 'positions');
if ~exist(positions_dir, 'dir')
    mkdir(positions_dir);
end
if ~exist('figures', 'dir')
    mkdir('figures');
end
if ~preloaded_positions
    delete('positions/*.mat');
end

%% Numero de RIS
S_values = (sqrt(L) + 1)^2;
for s = 1:length(S_values)
    S = S_values(s);
    S = 0;
    setup_seed = 9;
    for n = 1:nbrOfSetups
        setup_seed = setup_seed + 1;
        disp(['Setup ' num2str(n) '/' num2str(nbrOfSetups) ' asistido por ' num2str(S) ' RIS']);

        % Generar posiciones y distancias (positions/positionsX.mat)
        if ~preloaded_positions
            [APpositions, RISpositions, UEpositions, wrapLocations, APpositionsWrapped] = positions_setup(L, K, squareLength, center_grid_factor, setup_seed);
        else
            filename = sprintf('positions/positions%d.mat', n);
            load(filename);
            center_grid_factor = calculate_center_grid_factor(APpositions, L, squareLength);
        end
        [dist_AP_UE, dist_RIS_UE, dist_AP_RIS, whichpos] = calculate_distances(APpositions, RISpositions, UEpositions, APpositionsWrapped, K, L, S, h_BS, h_UT, h_RIS);

        % Guardar posiciones
        file_index = n;
        filename = "positions/positions" + file_index + ".mat";
        save(filename, "APpositions", "RISpositions", "UEpositions", "wrapLocations", "APpositionsWrapped", "dist_AP_UE", "dist_RIS_UE", "dist_AP_RIS", "whichpos");

        % Asignacion de RIS
        % Asignar todos los usuarios a todas las RISs
        for aux = 1:S
          % risAssignment{aux} = 1:K;     % Asignar todos los usuarios a cada RIS
          % risAssignment{aux} = randi(K); % Asignación un usuario por RIS aleatorio
            risAssignment{aux} = [];
            
        end

        % Generar escenario
        seed = randi(1000);
        [R_AP_UE,R_AP_RIS1,R_AP_RIS2,R_RIS_UE,pilotIndex,D,HMean_AP_UE, HMean_AP_RIS, HMean_RIS_UE, probLoS_AP_UE, probLoS_RIS_UE, dist_RIS_UE, UEpositions] = setup(L,K,N_AP,N_RIS,tau_p,seed,ASD_varphi,LoS,fc,S, APpositions, RISpositions, UEpositions, wrapLocations, APpositionsWrapped, h_BS, h_UT, h_RIS);                              

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

%% Graficar resultados
figure; hold on; box on;
set(gca,'fontsize',16);

% P-MMSE
aux1 = SE_PMMSE_DCC(:,:,1); % 0 RIS

plot(sort(aux1(:)), linspace(0,1,K*nbrOfSetups), 'k-', 'LineWidth', 2);

% Ejes y leyenda
xlabel('Spectral efficiency [bit/s/Hz]', 'Interpreter', 'Latex');
ylabel('CDF', 'Interpreter', 'Latex');
legend_text = sprintf('P-MMSE %d RIS', S);
legend({legend_text}, 'Interpreter', 'Latex', 'Location', 'SouthEast');
xlim([0 25]);
