% Script para extraer la SE a 60m (CDF=0.1)
clear; clc; close all;

factores = 0:10:100;
target_cdf = 0.1;
archivo_salida = 'se_60m_cdf01.txt';

fid = fopen(archivo_salida, 'w');
fprintf(fid, '=================================================================================\n');
fprintf(fid, 'Eficiencia Espectral para RIS a 60 metros (CDF = %.1f)\n', target_cdf);
fprintf(fid, '=================================================================================\n');
fprintf(fid, '%-10s | %-30s | %-30s\n', 'Factor', 'Modo Original (Compartido)', 'Modo Exclusivo');
fprintf(fid, '---------------------------------------------------------------------------------\n');

for f_idx = 1:length(factores)
    factor_val = factores(f_idx);
    
    % Original
    carpeta_orig = sprintf('figures/square1000m/factor%d_tauc10k', factor_val);
    archivo_orig = fullfile(carpeta_orig, sprintf('GridFactor%d_RIS60m_AP31m.fig', factor_val));
    se_orig = NaN;
    
    if exist(archivo_orig, 'file')
        figTemp = openfig(archivo_orig, 'invisible');
        objLinea = findobj(gca(figTemp), 'Type', 'line');
        if ~isempty(objLinea)
            xData = get(objLinea(1), 'XData');
            yData = get(objLinea(1), 'YData');
            [uniqueY, idx] = unique(yData);
            if length(uniqueY) > 1
                se_orig = interp1(uniqueY, xData(idx), target_cdf, 'linear', NaN);
            end
        end
        close(figTemp);
    end
    
    % Exclusivo
    carpeta_excl = sprintf('figures/square1000m/factor%d_tauc10k_exclusive', factor_val);
    archivo_excl = fullfile(carpeta_excl, sprintf('GridFactor%d_RIS60m_AP31m.fig', factor_val));
    se_excl = NaN;
    
    if exist(archivo_excl, 'file')
        figTemp = openfig(archivo_excl, 'invisible');
        objLinea = findobj(gca(figTemp), 'Type', 'line');
        if ~isempty(objLinea)
            xData = get(objLinea(1), 'XData');
            yData = get(objLinea(1), 'YData');
            [uniqueY, idx] = unique(yData);
            if length(uniqueY) > 1
                se_excl = interp1(uniqueY, xData(idx), target_cdf, 'linear', NaN);
            end
        end
        close(figTemp);
    end
    
    % Formatear salida
    if isnan(se_orig)
        str_orig = 'No data';
    else
        str_orig = sprintf('%.4f bit/s/Hz', se_orig);
    end
    
    if isnan(se_excl)
        str_excl = 'No data';
    else
        str_excl = sprintf('%.4f bit/s/Hz', se_excl);
    end
    
    fprintf(fid, '%-10.1f | %-30s | %-30s\n', factor_val/100, str_orig, str_excl);
end

fprintf(fid, '=================================================================================\n');
fclose(fid);
fprintf('Resultados de 60m guardados en %s\n', archivo_salida);
