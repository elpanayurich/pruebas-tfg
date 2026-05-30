% Script para encontrar el mejor radio en CDF = 0.1
clear; clc; close all;

carpetas = {'figures/square1000m/factor50_tauc10k', 'figures/square1000m/factor50_tauc10k_exclusive'};
nombres = {'Modo Compartido (Original)', 'Modo Exclusivo (1 RIS max)'};
target_cdf = 0.1;

for c_idx = 1:length(carpetas)
    carpeta = carpetas{c_idx};
    fprintf('\nAnalizando: %s\n', nombres{c_idx});
    
    if ~exist(carpeta, 'dir')
        fprintf('  Carpeta no encontrada.\n');
        continue;
    end
    
    archivos_info = dir(fullfile(carpeta, 'GridFactor50_RIS*_AP31m.fig'));
    num_archivos = length(archivos_info);
    
    if num_archivos == 0
        fprintf('  No hay archivos.\n');
        continue;
    end
    
    mejor_radio = -1;
    mejor_valor_se = -Inf;
    
    resultados = zeros(num_archivos, 2); % [radio, valor_se]
    
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
                
                resultados(i, :) = [radio, se_at_01];
                
                if se_at_01 > mejor_valor_se
                    mejor_valor_se = se_at_01;
                    mejor_radio = radio;
                end
            end
        end
        close(figTemp);
    end
    
    % Mostrar resultados ordenados opcionalmente si se requiere mas detalle, pero daremos el mejor
    fprintf('  => Mejor radio a CDF=%.1f: %d m (Eficiencia Espectral: %.4f bit/s/Hz)\n', target_cdf, mejor_radio, mejor_valor_se);
end