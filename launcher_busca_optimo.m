% launcher_busca_optimo.m
% Script para simular un escenario especifico y buscar el radio optimo absoluto
% con precision de 5 metros, centrado en la prediccion de la formula empirica.

clear; clc; close all;

% =========================================================================
% 1. PARAMETROS DEL ESCENARIO (Modifica estos valores para tu prueba)
% =========================================================================
tau_c = 10000;          % Longitud del bloque de coherencia
squareLength = 1000;    % Tamano del area de cobertura (ej. 1000m x 1000m)
N_RIS = 64;             % Numero de metaatomos por RIS
L = 16;                 % Numero de AP -> Ten en cuenta que es grid, el numero de RIS irá acorde
K = 15;                 % Numero de UE

% Configuracion fija de la simulacion
% assignment_mode puede ser:
% - 'inclusive': Múltiples RIS pueden compartir al mismo usuario simultáneamente.
% - 'exclusive': Asignación 1 a 1 estricta (1 RIS atiende máximo a 1 Usuario).
% - 'final': Aplica el Algoritmo Final con cálculo automático del radio óptimo interno.
assignment_mode = 'exclusive';
center_grid_factor = 0.5;
nbrOfSetups = 10; % Subir a 50 para resultados definitivos
target_cdf = 0.1;

% =========================================================================
% 2. CALCULO DE LA FORMULA Y DEFINICION DEL BARRIDO
% =========================================================================
% Calculo del parametro D_AP (distancia entre APs)
APperdim = sqrt(L);
D_AP = squareLength / APperdim;

% Ecuacion Empirica Unificada del TFG
R_pred = (0.25 * D_AP) * sqrt((64 / N_RIS) * (tau_c / 10000));

% Centrar el barrido en el valor predecido, redondeando a los 5m mas cercanos
R_base = round(R_pred / 5) * 5;

% Barrido de -25m a +25m en pasos de 5m
start_r = max(0, R_base - 25);
end_r = R_base + 25;
radios_a_probar = start_r:5:end_r;

mejor_radio = -1;
mejor_se = -Inf;

fprintf('========================================================\n');
fprintf('   BUSQUEDA DEL RADIO OPTIMO (Precision 5m)\n');
fprintf('========================================================\n');
fprintf(' Parametros: tau_c=%d, Area=%dm, N_RIS=%d\n', tau_c, squareLength, N_RIS);
fprintf(' Formula TFG estima: %.1f m\n', R_pred);
fprintf(' Intervalo de barrido simulado: [%d : 5 : %d] m\n\n', start_r, end_r);

% =========================================================================
% 3. EJECUCION DE LA SIMULACION
% =========================================================================
for r = radios_a_probar
    RIS_radius = r;
    
    % Fijar semilla para comparacion justa
    rng(123); global_seed = 123;
    
    try
        run('main1.m');
        
        aux = SE_PMMSE_DCC(:,:,1);
        sorted_se = sort(aux(:));
        se_val = sorted_se(max(1, round(target_cdf * length(sorted_se))));
        
        fprintf('  [Simulacion] Probando Radio %3d m -> SE = %.4f bit/s/Hz\n', r, se_val);
        
        if se_val > mejor_se
            mejor_se = se_val;
            mejor_radio = r;
        end
    catch ME
        fprintf('  [ERROR] Simulando radio %d m: %s\n', r, ME.message);
    end
end

fprintf('\n========================================================\n');
fprintf('=> RADIO OPTIMO SIMULADO ENCONTRADO: %d m (SE: %.4f)\n', mejor_radio, mejor_se);
fprintf('=> Diferencia con la formula: %.1f m\n', abs(mejor_radio - R_pred));
fprintf('========================================================\n');
