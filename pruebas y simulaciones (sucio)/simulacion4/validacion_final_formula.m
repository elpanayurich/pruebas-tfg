% validacion_final_formula.m
clear; clc; close all;

assignment_mode = 'exclusive';
center_grid_factor = 0.5;
nbrOfSetups = 10; % 10 setups para rapidez en la validacion
target_cdf = 0.1;

% Escenarios completamente cruzados: [tau_c, squareLength, N_RIS]
scenarios = [
    5000,   500,  32;   % Esc 1: Recursos bajos, area pequeña, pocos atomos
    15000, 1500, 128;   % Esc 2: Recursos altos, area grande, muchos atomos
    8000,   800,  16;   % Esc 3: Recursos medios, area media, poquisimos atomos
    20000, 1000, 256    % Esc 4: Recursos super altos, area estandar, muchisimos atomos
];

archivo_salida = 'resultados_validacion_final_formula.txt';
fid = fopen(archivo_salida, 'w');
fprintf(fid, '=================================================================\n');
fprintf(fid, '   VALIDACION FINAL DE LA ECUACION EMPIRICA UNIFICADA\n');
fprintf(fid, '=================================================================\n\n');
fclose(fid);

for s_idx = 1:size(scenarios,1)
    tau_c = scenarios(s_idx, 1);
    squareLength = scenarios(s_idx, 2);
    N_RIS = scenarios(s_idx, 3);
    
    D_AP = squareLength / 4;
    
    % --- LA NUEVA FORMULA UNIFICADA ---
    R_pred = (0.25 * D_AP) * sqrt((64 / N_RIS) * (tau_c / 10000));
    
    % Redondear la prediccion a decenas
    R_base = round(R_pred / 10) * 10;
    
    % Barrido de -30m a +30m alrededor de la prediccion
    start_r = max(0, R_base - 30);
    end_r = R_base + 30;
    radios_a_probar = start_r:10:end_r;
    
    mejor_radio_sq = -1;
    mejor_se_sq = -Inf;
    se_formula = 0; % SE lograda si usaramos estrictamente el radio de la formula
    
    fprintf('\n>>> ESCENARIO %d: tau_c=%d, D_AP=%.1f, N_RIS=%d | Formula=%.1f m (R_base=%d) <<<\n', s_idx, tau_c, D_AP, N_RIS, R_pred, R_base);
    
    for r = radios_a_probar
        RIS_radius = r;
        semilla = 999 + s_idx; 
        rng(semilla);
        global_seed = semilla;
        
        try
            run('main1.m');
            
            aux = SE_PMMSE_DCC(:,:,1); 
            sorted_se = sort(aux(:));
            se_val = sorted_se(max(1, round(target_cdf * length(sorted_se))));
            
            fprintf('  Radio %3d m -> SE = %.4f bit/s/Hz\n', r, se_val);
            
            if r == R_base
                se_formula = se_val;
            end
            
            if se_val > mejor_se_sq
                mejor_se_sq = se_val;
                mejor_radio_sq = r;
            end
        catch ME
            fprintf('  [ERROR] Radio %d m: %s\n', r, ME.message);
        end
    end
    
    fid = fopen(archivo_salida, 'a');
    fprintf(fid, 'ESCENARIO %d: tau_c=%d | Area=%dm (D_AP=%.1f) | N_RIS=%d\n', s_idx, tau_c, squareLength, D_AP, N_RIS);
    fprintf(fid, '  Radio Predicho (Formula): %.1f m (Usamos %d m)\n', R_pred, R_base);
    fprintf(fid, '  Radio Optimo (Simulado):  %d m\n', mejor_radio_sq);
    fprintf(fid, '  SE con Formula:           %.4f\n', se_formula);
    fprintf(fid, '  SE Optima:                %.4f\n', mejor_se_sq);
    fprintf(fid, '  Perdida SE:               %.2f%%\n', 100*(1 - se_formula/mejor_se_sq));
    fprintf(fid, '-----------------------------------------------------------------\n');
    fclose(fid);
end

fprintf('\nValidacion Finalizada. Resultados guardados en %s\n', archivo_salida);
