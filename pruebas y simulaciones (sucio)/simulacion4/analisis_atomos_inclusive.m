% analisis_atomos_inclusive.m
clear; clc; close all;

% Configuracion general
assignment_mode = 'inclusive'; % Usará assignRIS_radius (múltiples RIS por usuario)
center_grid_factor = 0.5;
nbrOfSetups = 50;
target_cdf = 0.1;
semilla = randi(10000);

% Array de escenarios
atomos = [4, 16, 32, 64, 128, 256];

archivo_salida = 'resultados_radio_vs_atomos_inclusive.txt';
fid = fopen(archivo_salida, 'w');
fprintf(fid, '=================================================================\n');
fprintf(fid, '   ANALISIS: RADIO OPTIMO (CDF=0.1) vs CANTIDAD DE ATOMOS (N_RIS)\n');
fprintf(fid, '=================================================================\n');
fprintf(fid, 'Factor 0.5 | Modo Inclusivo | 50 Setups\n\n');
fclose(fid);

% Matriz para guardar resultados [atomos, MejorRadio, MejorSE]
resultados_finales = zeros(length(atomos), 3);

for s_idx = 1:length(atomos)
    semilla = randi(10000);
    sq = atomos(s_idx);
    N_RIS = sq;
    
    fprintf('\n\n>>> INICIANDO N_RIS = %d <<<\n', sq);
    
    % Rango amplio para asegurar que cruzamos la barrera de solapamiento (>125m)
    % Usamos un paso de 20m para abarcar de 10 a 250 sin que la simulación tarde días
    radios_a_probar = 10:20:250;
    
    mejor_radio_sq = -1;
    mejor_se_sq = -Inf;
    
    fid = fopen(archivo_salida, 'a');
    fprintf(fid, '--- ATOMOS: %d ---\n', sq);
    
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
            
            fprintf('  N_RIS %d | Radio %3d m -> SE = %.4f bit/s/Hz\n', sq, r, se_val);
            fprintf(fid, '  Radio %3d m -> SE = %.4f\n', r, se_val);
            
            if se_val > mejor_se_sq
                mejor_se_sq = se_val;
                mejor_radio_sq = r;
            end
            
        catch ME
            fprintf('  [ERROR] en N_RIS %d, Radio %d m: %s\n', sq, r, ME.message);
        end
    end
    
    resultados_finales(s_idx, :) = [sq, mejor_radio_sq, mejor_se_sq];
    
    fprintf('=> MEJOR RADIO PARA %d: %d m (SE: %.4f)\n', sq, mejor_radio_sq, mejor_se_sq);
    fprintf(fid, '=> OPTIMO PARA %d: Radio = %d m (SE = %.4f)\n\n', sq, mejor_radio_sq, mejor_se_sq);
    fclose(fid);
end

% Guardar el resumen final en tabla
fid = fopen(archivo_salida, 'a');
fprintf(fid, '=================================================================\n');
fprintf(fid, 'TABLA RESUMEN FINAL\n');
fprintf(fid, '=================================================================\n');
fprintf(fid, 'N_RIS | Radio Optimo [m] | Mejor SE (CDF=0.1) [bit/s/Hz]\n');
fprintf(fid, '-----------------------------------------------------------------\n');
for i = 1:length(atomos)
    fprintf(fid, '%-16d | %-16d | %.4f\n', resultados_finales(i,1), resultados_finales(i,2), resultados_finales(i,3));
end
fprintf(fid, '=================================================================\n');
fclose(fid);

fprintf('\nAnalisis Finalizado. Resultados guardados en %s\n', archivo_salida);
