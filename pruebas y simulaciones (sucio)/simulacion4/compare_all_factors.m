% Script para comparar el mejor radio a CDF = 0.1 entre modo original y exclusivo
clear; clc; close all;

factores = 0:10:100;
target_cdf = 0.1;

fprintf('=================================================================================\n');
fprintf('Comparacion del Mejor Radio RIS (CDF = %.1f) - Original vs Exclusivo\n', target_cdf);
fprintf('=================================================================================\n');
fprintf('%-10s | %-30s | %-30s\n', 'Factor', 'Modo Original (Compartido)', 'Modo Exclusivo (1 RIS max)');
fprintf('---------------------------------------------------------------------------------\n');

for f_idx = 1:length(factores)
    factor_val = factores(f_idx);
    
    % Carpetas
    carpeta_orig = sprintf('figures/square1000m/factor%d_tauc10k', factor_val);
    carpeta_excl = sprintf('figures/square1000m/factor%d_tauc10k_exclusive', factor_val);
    
    mejor_radio_orig = -1;
    mejor_se_orig = -Inf;
    
    mejor_radio_excl = -1;
    mejor_se_excl = -Inf;
    
    % Procesar original
    if exist(carpeta_orig, 'dir')
        archivos = dir(fullfile(carpeta_orig, sprintf('GridFactor%d_RIS*_AP31m.fig', factor_val)));
        for i = 1:length(archivos)
            nombre = archivos(i).name;
            idx1 = strfind(nombre, 'RIS') + 3;
            idx2 = strfind(nombre, 'm_AP') - 1;
            radio = str2double(nombre(idx1:idx2));
            
            figTemp = openfig(fullfile(carpeta_orig, nombre), 'invisible');
            axTemp = gca(figTemp);
            objLinea = findobj(axTemp, 'Type', 'line'); 
            
            if ~isempty(objLinea)
                xData = get(objLinea(1), 'XData');
                yData = get(objLinea(1), 'YData');
                [uniqueY, idx] = unique(yData);
                if length(uniqueY) > 1
                    se_at_01 = interp1(uniqueY, xData(idx), target_cdf, 'linear', NaN);
                    if se_at_01 > mejor_se_orig
                        mejor_se_orig = se_at_01;
                        mejor_radio_orig = radio;
                    end
                end
            end
            close(figTemp);
        end
    end
    
    % Procesar exclusivo
    if exist(carpeta_excl, 'dir')
        archivos = dir(fullfile(carpeta_excl, sprintf('GridFactor%d_RIS*_AP31m.fig', factor_val)));
        for i = 1:length(archivos)
            nombre = archivos(i).name;
            idx1 = strfind(nombre, 'RIS') + 3;
            idx2 = strfind(nombre, 'm_AP') - 1;
            radio = str2double(nombre(idx1:idx2));
            
            figTemp = openfig(fullfile(carpeta_excl, nombre), 'invisible');
            axTemp = gca(figTemp);
            objLinea = findobj(axTemp, 'Type', 'line'); 
            
            if ~isempty(objLinea)
                xData = get(objLinea(1), 'XData');
                yData = get(objLinea(1), 'YData');
                [uniqueY, idx] = unique(yData);
                if length(uniqueY) > 1
                    se_at_01 = interp1(uniqueY, xData(idx), target_cdf, 'linear', NaN);
                    if se_at_01 > mejor_se_excl
                        mejor_se_excl = se_at_01;
                        mejor_radio_excl = radio;
                    end
                end
            end
            close(figTemp);
        end
    end
    
    % Formatear strings de salida
    if mejor_radio_orig == -1
        str_orig = 'No data';
    else
        str_orig = sprintf('%d m (SE: %.4f)', mejor_radio_orig, mejor_se_orig);
    end
    
    if mejor_radio_excl == -1
        str_excl = 'No data';
    else
        str_excl = sprintf('%d m (SE: %.4f)', mejor_radio_excl, mejor_se_excl);
    end
    
    fprintf('%-10.1f | %-30s | %-30s\n', factor_val/100, str_orig, str_excl);
end
fprintf('=================================================================================\n');