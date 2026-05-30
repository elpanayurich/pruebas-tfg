% analisis_tauc_inclusive.m
clear; clc; close all;

% Configuracion general
assignment_mode = 'inclusive'; % Cambio a modo inclusivo (usará assignRIS_radius)
center_grid_factor = 0.5;
nbrOfSetups = 50;
target_cdf = 0.1;
semilla = randi(10000);

% Array de escenarios
taucs = [1000, 4000, 7000, 10000, 13000, 17000, 20000];

archivo_salida = 'resultados_radio_vs_tauc_inclusive.txt';
fid = fopen(archivo_salida, 'w');
fprintf(fid, '=================================================================\n');
fprintf(fid, '   ANALISIS: RADIO OPTIMO (CDF=0.1) vs TAMAÑO DE TUA_C (tau_c)\n');
fprintf(fid, '=================================================================\n');
fprintf(fid, 'Factor 0.5 | Modo Inclusivo (Multiple RIS per UE) | 50 Setups\n\n');
fclose(fid);

% Matriz para guardar resultados [tauc, MejorRadio, MejorSE]
resultados_finales = zeros(length(taucs), 3);

for s_idx = 1:length(taucs)
    semilla = randi(10000);
    sq = taucs(s_idx);
    tau_c = sq;
    
    fprintf('\n\n>>> INICIANDO tau_c = %d m <<<\n', sq);
    
    % Definir rango de radios según el tamaño
    if sq <= 10000
        radios_a_probar = 0:10:80;
    else
        radios_a_probar = 70:10:140;
    end
    
    mejor_radio_sq = -1;
    mejor_se_sq = -Inf;
    
    fid = fopen(archivo_salida, 'a');
    fprintf(fid, '--- TAUC: %d m ---\n', sq);
    
    for r_idx = 1:length(radios_a_probar)
        r = radios_a_probar(r_idx);
        global_seed = semilla;
        rng(semilla);
        
        RIS_radius = r;
        
        try
            run('main1.m');
            
            aux = SE_PMMSE_DCC(:,:,1); 
            sorted_se = sort(aux(:));
            idx = max(1, round(target_cdf * length(sorted_se)));
            se_val = sorted_se(idx);
            
            fprintf('  tau_c %d m | Radio %3d m -> SE = %.4f bit/s/Hz\n', sq, r, se_val);
            fprintf(fid, '  Radio %3d m -> SE = %.4f\n', r, se_val);
            
            if se_val > mejor_se_sq
                mejor_se_sq = se_val;
                mejor_radio_sq = r;
            end
            
        catch ME
            fprintf('  [ERROR] en tau_c %d m, Radio %d m: %s\n', sq, r, ME.message);
        end
    end
    
    resultados_finales(s_idx, :) = [sq, mejor_radio_sq, mejor_se_sq];
    
    fprintf('=> MEJOR RADIO PARA %d m: %d m (SE: %.4f)\n', sq, mejor_radio_sq, mejor_se_sq);
    fprintf(fid, '=> OPTIMO PARA %d m: Radio = %d m (SE = %.4f)\n\n', sq, mejor_radio_sq, mejor_se_sq);
    fclose(fid);
end

% Guardar el resumen final en tabla
fid = fopen(archivo_salida, 'a');
fprintf(fid, '=================================================================\n');
fprintf(fid, 'TABLA RESUMEN FINAL\n');
fprintf(fid, '=================================================================\n');
fprintf(fid, 'tau_c | Radio Optimo [m] | Mejor SE (CDF=0.1) [bit/s/Hz]\n');
fprintf(fid, '-----------------------------------------------------------------\n');
for i = 1:length(taucs)
    fprintf(fid, '%-16d | %-16d | %.4f\n', resultados_finales(i,1), resultados_finales(i,2), resultados_finales(i,3));
end
fprintf(fid, '=================================================================\n');
fclose(fid);

fprintf('\nAnalisis 2D Finalizado. Resultados guardados en %s\n', archivo_salida);
