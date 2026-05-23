% main_simulations.m - Clean unified simulation script
clear;
close all;

%% Setup de simulación
nbrOfSetups = 10;   % Número de escenarios
nbrOfRealizations = 100;    % Número de realizaciones

L = 16;          % Número de APs
N_AP = 1;        % Antenas por AP
N_RIS = 64;      % Número de elementos de la RIS
K = 10;          % Número de UEs 
tau_c = 10000;   % Longitud del bloque de coherencia
p = 100;         % Potencia de transmisión (mW)
fc = 3.5;        % Frecuencia (GHz)
LoS = 2;         % Linea de visión directa
ASD_varphi = deg2rad(15);  % angulo de azimut

S = (sqrt(L) + 1)^2; % Numero de RISs (25)

cases = {'all', 'random_2', 'random_1', 'closest_2', 'closest_1', 'no_assignment', 'closest_K_unassigned'};
num_cases = length(cases);
SE_results = cell(num_cases, 1);

% Crear carpeta de figuras limpia si no existe
if ~exist('figures_clean', 'dir')
    mkdir('figures_clean');
end

%% Run Simulations
for c_idx = 1:num_cases
    case_name = cases{c_idx};
    fprintf('Running Case %d/%d: %s...\n', c_idx, num_cases, case_name);
    
    % Calcular tau_p (Longitud del piloto)
    if strcmp(case_name, 'all')
        tau_p = S * K * (1 + N_RIS) + K;
    elseif strcmp(case_name, 'random_2') || strcmp(case_name, 'closest_2')
        tau_p = S * 2 * (1 + N_RIS) + K;
    elseif strcmp(case_name, 'random_1') || strcmp(case_name, 'closest_1')
        tau_p = S * 1 * (1 + N_RIS) + K;
    elseif strcmp(case_name, 'no_assignment')
        tau_p = K; % No RIS elements assigned, pilot length is just K
    end
    
    SE_PMMSE_case = zeros(K, nbrOfSetups);
    setup_seed = 9;
    
    for n = 1:nbrOfSetups
        fprintf('  Setup %d/%d...\n', n, nbrOfSetups);
        
        % Generar escenario
        seed = randi(1000);
        setup_seed = setup_seed + 1;
        [R_AP_UE, R_AP_RIS1, R_AP_RIS2, R_RIS_UE, pilotIndex, D, HMean_AP_UE, HMean_AP_RIS, HMean_RIS_UE, probLoS_AP_UE, probLoS_RIS_UE, dist_RIS_UE, UEpositions] = setup(L, K, N_AP, N_RIS, tau_p, seed, ASD_varphi, LoS, fc, S, setup_seed);
        
        % Asignacion de RIS dinámica usando las distancias precalculadas
        if strcmp(case_name, 'no_assignment')
            risAssignment = []; % Pass empty assignment for no assignment
        else
            risAssignment = cell(S, 1);
            if strcmp(case_name, 'all')
                for aux = 1:S
                    risAssignment{aux} = 1:K;
                end
            elseif strcmp(case_name, 'random_2')
                for aux = 1:S
                    risAssignment{aux} = randperm(K, 2);
                end
            elseif strcmp(case_name, 'random_1')
                for aux = 1:S
                    risAssignment{aux} = randi(K);
                end
            elseif strcmp(case_name, 'closest_2')
                for aux = 1:S
                    [~, sorted_indices] = sort(dist_RIS_UE(aux, :), 'ascend');
                    risAssignment{aux} = sorted_indices(1:2);
                end
            elseif strcmp(case_name, 'closest_1')
                for aux = 1:S
                    [~, closest_idx] = min(dist_RIS_UE(aux, :));
                    risAssignment{aux} = closest_idx;
                end
            end
        end
        
        % Estimar canales
        [Hhat, H_eq, R_eq, B, C] = channelEstimates(R_AP_UE, R_AP_RIS1, R_AP_RIS2, R_RIS_UE, nbrOfRealizations, L, K, S, N_AP, N_RIS, tau_p, pilotIndex, p, HMean_AP_UE, HMean_AP_RIS, HMean_RIS_UE, risAssignment);
        
        % Calcular SE
        [SE_P_MMSE, ~] = SE_uplink(Hhat, H_eq, D, B, C, tau_c, tau_p, nbrOfRealizations, N_AP, K, L, p, R_eq, pilotIndex);
        
        % Guardar resultados de este setup
        SE_PMMSE_case(:, n) = SE_P_MMSE;
    end
    SE_results{c_idx} = SE_PMMSE_case;
    
    % --- Save Individual Figure for the case ---
    fig_ind = figure('Visible', 'off'); hold on; box on;
    set(gca,'fontsize',16);
    plot(sort(SE_PMMSE_case(:)), linspace(0,1,K*nbrOfSetups), 'k-', 'LineWidth', 2);
    xlabel('Spectral efficiency [bit/s/Hz]', 'Interpreter', 'Latex');
    ylabel('CDF', 'Interpreter', 'Latex');
    xlim([0 25]);
    grid on;
    fig_filename = fullfile('figures_clean', [case_name '.fig']);
    savefig(fig_ind, fig_filename);
    close(fig_ind);
    fprintf('  Guardada figura individual: %s\n', fig_filename);
end

% Guardar todos los resultados comparativos
save('results_comparison.mat', 'SE_results', 'cases', 'K', 'nbrOfSetups');
fprintf('Simulaciones completadas y guardadas en results_comparison.mat.\n');

%% Graficar resultados
fig = figure; hold on; box on;
set(gca,'fontsize',16);
colors = {'k-', 'b-', 'r-', 'g-', 'm-', 'c-', 'y-'};
legends = cell(num_cases, 1);

for c_idx = 1:num_cases
    aux = SE_results{c_idx};
    plot(sort(aux(:)), linspace(0,1,K*nbrOfSetups), colors{c_idx}, 'LineWidth', 2);
    
    % Formatear leyenda
    c_name = strrep(cases{c_idx}, '_', ' ');
    legends{c_idx} = sprintf('P-MMSE (%s)', c_name);
end

xlabel('Spectral efficiency [bit/s/Hz]', 'Interpreter', 'Latex');
ylabel('CDF', 'Interpreter', 'Latex');
legend(legends, 'Interpreter', 'Latex', 'Location', 'SouthEast');
xlim([0 25]);
grid on;

% Crear carpeta de figuras limpia si no existe
if ~exist('figures_clean', 'dir')
    mkdir('figures_clean');
end
savefig(fig, fullfile('figures_clean', 'Comparison_CDF.fig'));
saveas(fig, fullfile('figures_clean', 'Comparison_CDF.png'));
close(fig);
fprintf('Figura comparativa guardada en figures_clean/Comparison_CDF.fig y .png\n');
