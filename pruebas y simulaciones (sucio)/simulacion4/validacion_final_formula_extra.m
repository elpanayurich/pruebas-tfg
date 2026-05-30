% validacion_final_formula_extra.m
clear; clc; close all;

assignment_mode = 'exclusive';
center_grid_factor = 0.5;
nbrOfSetups = 10; % 10 setups para agilizar
target_cdf = 0.1;

% Nuevos escenarios cruzados: [tau_c, squareLength, N_RIS]
% Evitamos N_RIS = 256 para que termine rápido
scenarios = [
    3000,   400,  16;   % Esc 1: tauc bajo, area enana, atomos bajos
    10000,  900,  32;   % Esc 2: tauc base, area media, atomos medios-bajos
    18000, 1100,  64;   % Esc 3: tauc alto, area grande, atomos base
    6000,  1600, 128;   % Esc 4: tauc medio-bajo, area enorme, atomos altos
    14000,  700,   8    % Esc 5: tauc medio-alto, area media-pequeña, atomos infimos
];

archivo_salida = 'resultados_validacion_final_formula_extra.txt';
fid = fopen(archivo_salida, 'w');
fprintf(fid, '=================================================================\n');
fprintf(fid, '   VALIDACION EXTRA DE LA ECUACION EMPIRICA UNIFICADA\n');
fprintf(fid, '=================================================================\n\n');
fclose(fid);

for s_idx = 1:size(scenarios,1)
    tau_c = scenarios(s_idx, 1);
    squareLength = scenarios(s_idx, 2);
    N_RIS = scenarios(s_idx, 3);
    
    D_AP = squareLength / 4;
    
    % --- FORMULA UNIFICADA ---
    R_pred = (0.25 * D_AP) * sqrt((64 / N_RIS) * (tau_c / 10000));
    R_base = round(R_pred / 10) * 10;
    
    % Barrido de -30m a +30m (con limite en 0)
    start_r = max(0, R_base - 30);
    end_r = R_base + 30;
    radios_a_probar = start_r:10:end_r;
    
    mejor_radio_sq = -1;
    mejor_se_sq = -Inf;
    se_formula = 0; 
    
    fprintf('\n>>> EXTRA ESC %d: tau_c=%d, D_AP=%.1f, N_RIS=%d | Formula=%.1f m (R_base=%d) <<<\n', s_idx, tau_c, D_AP, N_RIS, R_pred, R_base);
    
    for r = radios_a_probar
        RIS_radius = r;
        semilla = 777 + s_idx; 
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
    fprintf(fid, 'ESCENARIO EXTRA %d: tau_c=%d | Area=%dm (D_AP=%.1f) | N_RIS=%d\n', s_idx, tau_c, squareLength, D_AP, N_RIS);
    fprintf(fid, '  Radio Predicho (Formula): %.1f m (Usamos %d m)\n', R_pred, R_base);
    fprintf(fid, '  Radio Optimo (Simulado):  %d m\n', mejor_radio_sq);
    fprintf(fid, '  SE con Formula:           %.4f\n', se_formula);
    fprintf(fid, '  SE Optima:                %.4f\n', mejor_se_sq);
    fprintf(fid, '  Perdida SE:               %.2f%%\n', 100*(1 - se_formula/mejor_se_sq));
    fprintf(fid, '-----------------------------------------------------------------\n');
    fclose(fid);
end

fprintf('\nValidacion Extra Finalizada. Resultados guardados en %s\n', archivo_salida);
