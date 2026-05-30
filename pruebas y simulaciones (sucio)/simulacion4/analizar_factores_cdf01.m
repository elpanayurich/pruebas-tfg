% Script para encontrar el mejor radio en CDF = 0.1 para diferentes factores
clear; clc; close all;

% Factores a analizar (los que ya estan generados)
factores = [0, 10]; 
target_cdf = 0.1;
archivo_salida = 'resultados_cdf01.txt';

fid = fopen(archivo_salida, 'a'); % Abrir en modo append para no sobreescribir
fprintf(fid, '=== Analisis de Mejor Radio a CDF=%.1f (Modo Exclusivo) ===\n', target_cdf);
fprintf(fid, 'Fecha: %s\n\n', datestr(now));

for f_idx = 1:length(factores)
    factor_val = factores(f_idx);
    carpeta = sprintf('figures/square1000m/factor%d_tauc10k_exclusive', factor_val);
    
    fprintf('Analizando factor %d...\n', factor_val);
    
    if ~exist(carpeta, 'dir')
        fprintf('  Carpeta %s no encontrada.\n', carpeta);
        continue;
    end
    
    archivos_info = dir(fullfile(carpeta, sprintf('GridFactor%d_RIS*_AP31m.fig', factor_val)));
    num_archivos = length(archivos_info);
    
    if num_archivos == 0
        fprintf('  No hay archivos en %s.\n', carpeta);
        continue;
    end
    
    mejor_radio = -1;
    mejor_valor_se = -Inf;
    
    for i = 1:num_archivos
        nombre = archivos_info(i).name;
        
        % Extraer radio
        idx1 = strfind(nombre, 'RIS') + 3;
        idx2 = strfind(nombre, 'm_AP') - 1;
        radio = str2double(nombre(idx1:idx2));
        
        rutaCompleta = fullfile(carpeta, nombre);
        figTemp = openfig(rutaCompleta, 'invisible');
        
        axTemp = gca(figTemp);
        objLinea = findobj(axTemp, 'Type', 'line'); 
        
        if ~isempty(objLinea)
            xData = get(objLinea(1), 'XData');
            yData = get(objLinea(1), 'YData');
            
            % Interpolate to find X (Spectral Efficiency) at Y = 0.1 (CDF)
            [uniqueY, idx] = unique(yData);
            if length(uniqueY) > 1
                se_at_01 = interp1(uniqueY, xData(idx), target_cdf, 'linear', NaN);
                
                if se_at_01 > mejor_valor_se
                    mejor_valor_se = se_at_01;
                    mejor_radio = radio;
                end
            end
        end
        close(figTemp);
    end
    
    resultado_str = sprintf('Factor %.1f (Carpeta factor%d): Mejor radio = %d m (Eficiencia Espectral = %.4f bit/s/Hz)\n', factor_val/100, factor_val, mejor_radio, mejor_valor_se);
    fprintf(resultado_str);
    fprintf(fid, '%s', resultado_str);
end

fprintf(fid, '\n------------------------------------------------------------\n');
fclose(fid);
fprintf('\nResultados guardados en %s\n', archivo_salida);
