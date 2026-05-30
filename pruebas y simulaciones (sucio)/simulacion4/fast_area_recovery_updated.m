% fast_area_recovery_updated.m
clear; clc; close all;

% Configuracion general
assignment_mode = 'exclusive';
center_grid_factor = 0.5;
nbrOfSetups = 50;
target_cdf = 0.1;
semilla_fija = 42;

% Array de escenarios y sus rangos especificos solicitados
% Usamos celdas para definir [min, max] por cada square
squares = [250, 500, 750, 1000, 1500, 1750, 2000];
rangos = { [10, 50], [10, 50], [10, 50], [40, 90], [50, 100], [60, 120], [60, 140] };

archivo_salida = 'resultados_area_vs_radio.txt';
% El archivo ya tiene los datos de 1250m rescatados. Usamos modo 'a' (append).

for s_idx = 1:length(squares)
    sq = squares(s_idx);
    squareLength = sq;
    r_min = rangos{s_idx}(1);
    r_max = rangos{s_idx}(2);
    
    fprintf('\n\n>>> RECUPERANDO SQUARELENGTH = %d m [%d, %d] <<<\n', sq, r_min, r_max);
    
    radios_a_probar = r_min:10:r_max;
    
    mejor_radio_sq = -1;
    mejor_se_sq = -Inf;
    
    fid = fopen(archivo_salida, 'a');
    fprintf(fid, '--- SQUARE: %d m ---\n', sq);
    
    for r_idx = 1:length(radios_a_probar)
        r = radios_a_probar(r_idx);
        
        % Forzar semilla determinista
        global_seed = semilla_fija;
        rng(semilla_fija);
        
        RIS_radius = r;
        
        try
            run('main1.m');
            aux = SE_PMMSE_DCC(:,:,1); 
            sorted_se = sort(aux(:));
            se_val = sorted_se(max(1, round(target_cdf * length(sorted_se))));
            
            fprintf('  Square %d m | Radio %3d m -> SE = %.4f\n', sq, r, se_val);
            fprintf(fid, '  Radio %3d m -> SE = %.4f\n', r, se_val);
            
            if se_val > mejor_se_sq
                mejor_se_sq = se_val;
                mejor_radio_sq = r;
            end
        catch ME
            fprintf('  [ERROR]: %s\n', ME.message);
        end
    end
    
    fprintf(fid, '=> OPTIMO PARA %d m: Radio = %d m (SE = %.4f)\n\n', sq, mejor_radio_sq, mejor_se_sq);
    fclose(fid);
end

fprintf('\nRecuperacion finalizada. Resultados añadidos a %s\n', archivo_salida);
