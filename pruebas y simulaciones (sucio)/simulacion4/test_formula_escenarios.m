% test_formula_escenarios.m
clear; clc; close all;

assignment_mode = 'exclusive';
center_grid_factor = 0.5;
nbrOfSetups = 10; % Reducido a 10 para acelerar la validacion
target_cdf = 0.1;

% [tau_c, squareLength, N_RIS]
scenarios = [
    15000, 1250, 32;   % Escenario 1
    5000,   800, 64;   % Escenario 2
    20000, 1500, 128;  % Escenario 3
    8000,   600, 16;   % Escenario 4
    12000, 1000, 256   % Escenario 5
];

archivo_salida = 'resultados_validacion_formula.txt';
fid = fopen(archivo_salida, 'w');
fprintf(fid, '=================================================================\n');
fprintf(fid, '   VALIDACION DE LA FORMULA DE ASIGNACION DE RIS\n');
fprintf(fid, '=================================================================\n\n');
fclose(fid);

for s_idx = 1:size(scenarios,1)
    tau_c = scenarios(s_idx, 1);
    squareLength = scenarios(s_idx, 2);
    N_RIS = scenarios(s_idx, 3);
    
    % Calcular D_AP. L = 16 APs, por lo que APperdim = 4. D_AP = squareLength / 4
    D_AP = squareLength / 4;
    
    % --- PREDICCION CON LA FORMULA ---
    R_pred = (0.25 * D_AP) * sqrt(64 / N_RIS) * min(1, max(0, log10(tau_c / 1000)));
    
    % Definir rango de radios a probar en la simulación (barrido de -40m a +40m respecto a la predicción)
    R_base = round(R_pred / 10) * 10;
    start_r = max(0, R_base - 40);
    end_r = R_base + 40;
    radios_a_probar = start_r:10:end_r;
    
    mejor_radio_sq = -1;
    mejor_se_sq = -Inf;
    
    fprintf('\n>>> ESCENARIO %d: tau_c=%d, sq=%d, N_RIS=%d | R_PRED=%.1f m <<<\n', s_idx, tau_c, squareLength, N_RIS, R_pred);
    
    for r = radios_a_probar
        RIS_radius = r;
        % Semilla fija para consistencia en la comparativa
        semilla = 1234 + s_idx; 
        rng(semilla);
        global_seed = semilla;
        
        try
            run('main1.m');
            
            aux = SE_PMMSE_DCC(:,:,1); 
            sorted_se = sort(aux(:));
            se_val = sorted_se(max(1, round(target_cdf * length(sorted_se))));
            
            fprintf('  Radio %3d m -> SE = %.4f bit/s/Hz\n', r, se_val);
            
            if se_val > mejor_se_sq
                mejor_se_sq = se_val;
                mejor_radio_sq = r;
            end
        catch ME
            fprintf('  [ERROR] Radio %d m: %s\n', r, ME.message);
        end
    end
    
    fid = fopen(archivo_salida, 'a');
    fprintf(fid, 'ESCENARIO %d:\n', s_idx);
    fprintf(fid, '  Parametros: tau_c = %d | Area = %d m | N_RIS = %d\n', tau_c, squareLength, N_RIS);
    fprintf(fid, '  Distancia entre APs (D_AP): %.1f m\n', D_AP);
    fprintf(fid, '  Radio Calculado (Formula):  %.1f m\n', R_pred);
    fprintf(fid, '  Radio Optimo (Simulado):    %d m (SE: %.4f)\n', mejor_radio_sq, mejor_se_sq);
    fprintf(fid, '-----------------------------------------------------------------\n');
    fclose(fid);
    
    fprintf('=> Optimo Simulado: %d m | Predicho: %.1f m\n', mejor_radio_sq, R_pred);
end

fprintf('\nValidacion Finalizada. Resultados guardados en %s\n', archivo_salida);
