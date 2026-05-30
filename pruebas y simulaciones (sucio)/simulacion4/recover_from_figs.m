% recover_from_figs.m
% Script para extraer datos de SE de los archivos .fig guardados antes del crash
clear; clc; close all;

archivo_salida = 'resultados_area_vs_radio.txt';
target_cdf = 0.1;
square_reaprovechar = 1250; % Los .fig en 'figures/' corresponden a este square

fprintf('Rescatando datos de los .fig en simulacion4/figures...\n');

% Abrir archivo para escribir la cabecera (esto borrara el archivo anterior corrupto)
fid = fopen(archivo_salida, 'w');
fprintf(fid, '=================================================================\n');
fprintf(fid, '   ANALISIS RESCATADO: RADIO OPTIMO (CDF=0.1) vs AREA\n');
fprintf(fid, '=================================================================\n');
fprintf(fid, 'Factor 0.5 | Modo Exclusivo | 50 Setups (RESCATADO DE .FIG)\n\n');
fprintf(fid, '--- SQUARE: %d m ---\n', square_reaprovechar);

% Listar los .fig en la carpeta figures/
archivos = dir('figures/GridFactor50_RIS*_AP31m.fig');
num_archivos = length(archivos);

resultados = []; % [radio, se_val]

for i = 1:num_archivos
    nombre = archivos(i).name;
    
    % Extraer radio
    tokens = regexp(nombre, 'RIS(\d+)m', 'tokens');
    if isempty(tokens)
        continue;
    end
    radio = str2double(tokens{1}{1});
    
    % Abrir figura e interpolar SE
    figTemp = openfig(fullfile('figures', nombre), 'invisible');
    objLinea = findobj(gca(figTemp), 'Type', 'line');
    
    if ~isempty(objLinea)
        xData = get(objLinea(1), 'XData');
        yData = get(objLinea(1), 'YData');
        [uniqueY, idx] = unique(yData);
        if length(uniqueY) > 1
            se_val = interp1(uniqueY, xData(idx), target_cdf, 'linear', NaN);
            
            fprintf('  Radio %3d m -> SE = %.4f (Rescatado)\n', radio, se_val);
            fprintf(fid, '  Radio %3d m -> SE = %.4f\n', radio, se_val);
            
            resultados = [resultados; radio, se_val];
        end
    end
    close(figTemp);
end

if ~isempty(resultados)
    [max_se, max_idx] = max(resultados(:, 2));
    mejor_r = resultados(max_idx, 1);
    fprintf('=> OPTIMO RESCATADO PARA %d m: Radio = %d m (SE = %.4f)\n', square_reaprovechar, mejor_r, max_se);
    fprintf(fid, '=> OPTIMO PARA %d m: Radio = %d m (SE = %.4f)\n\n', square_reaprovechar, mejor_r, max_se);
end

fclose(fid);
fprintf('Archivo %s inicializado con datos rescatados de 1250m.\n', archivo_salida);
