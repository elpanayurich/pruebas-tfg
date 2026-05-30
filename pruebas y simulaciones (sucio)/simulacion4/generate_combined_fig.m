% Script para combinar figuras de simulacion4 en formato oscuro
clear; clc; close all;

% Directorios
carpeta_origen = 'figures/square1000m/factor50_tauc10k_exclusive';
carpeta_destino = 'results_memoria';

if ~exist(carpeta_destino, 'dir')
    mkdir(carpeta_destino);
end

% Obtener todos los archivos .fig de la carpeta origen
archivos_info = dir(fullfile(carpeta_origen, 'GridFactor50_RIS*_AP31m.fig'));
num_archivos = length(archivos_info);

% Extraer la distancia de cada archivo para ordenarlos
distancias = zeros(1, num_archivos);
for i = 1:num_archivos
    nombre = archivos_info(i).name;
    % Extraer numero entre RIS y m
    idx1 = strfind(nombre, 'RIS') + 3;
    idx2 = strfind(nombre, 'm_AP') - 1;
    distancias(i) = str2double(nombre(idx1:idx2));
end

% Ordenar archivos por distancia
[distancias_ordenadas, idx_orden] = sort(distancias);
archivos_ordenados = archivos_info(idx_orden);

% Crear figura con FONDO OSCURO y definir EJES EXPLÍCITOS
figPrincipal = figure('Name', 'Resultados Combinados simulacion4', 'Color', [0.15 0.15 0.15]); 
axPrincipal = axes(figPrincipal); 
hold(axPrincipal, 'on'); 

% Preparar colores (solo necesitamos colores para los resaltados)
num_resaltados = ceil(num_archivos / 4);
coloresBase = lines(num_resaltados);
color_gris = [0.4 0.4 0.4];

hLineas_leyenda = [];
etiquetas_leyenda = {};

color_idx = 1;

for i = 1:num_archivos
    rutaCompleta = fullfile(carpeta_origen, archivos_ordenados(i).name);
    figTemp = openfig(rutaCompleta, 'invisible');
    
    axTemp = gca(figTemp);
    objLinea = findobj(axTemp, 'Type', 'line'); 
    
    xData = get(objLinea(1), 'XData');
    yData = get(objLinea(1), 'YData');
    
    saltoMarcador = max(1, round(length(xData) / 15)); 
    
    es_resaltado = (mod(i-1, 4) == 0);
    
    if es_resaltado
        hL = plot(axPrincipal, xData, yData, ...
            'Color', coloresBase(color_idx, :), ...
            'LineStyle', '-', ...
            'LineWidth', 2, ...
            'DisplayName', sprintf('RIS a %d m', distancias_ordenadas(i)));
        
        hLineas_leyenda = [hLineas_leyenda, hL];
        etiquetas_leyenda{end+1} = sprintf('RIS a %d m', distancias_ordenadas(i));
        color_idx = color_idx + 1;
    else
        plot(axPrincipal, xData, yData, ...
            'Color', color_gris, ...
            'LineStyle', '-', ...
            'LineWidth', 1, ...
            'HandleVisibility', 'off'); % No aparecer en leyenda
    end
    
    close(figTemp);
end

hold(axPrincipal, 'off');

% Formato del gráfico adaptado a TEMA OSCURO (UNIFICADO)
grid(axPrincipal, 'on');
box(axPrincipal, 'on');
axPrincipal.Color = [0.1 0.1 0.1]; 
axPrincipal.XColor = 'w'; 
axPrincipal.YColor = 'w'; 
axPrincipal.FontSize = 11;
axPrincipal.GridAlpha = 0.3; 
xlabel(axPrincipal, 'Eficiencia espectral [bit/s/Hz]', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'w');
ylabel(axPrincipal, 'CDF', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'w');

% Ajustar márgenes explícitamente (Izquierdo: 0.065, Derecho: 0.065, Arriba: 0.078, Abajo: 0.078)
axPrincipal.Position = [0.065, 0.078, 0.87, 0.844];

% Leyenda estilo "Cuadrado Pro" con recuadro integrado
lgd = legend(axPrincipal, hLineas_leyenda, etiquetas_leyenda, 'Location', 'best', 'FontSize', 11, 'Box', 'on');
lgd.TextColor = 'w';
lgd.Color = [0.15 0.15 0.15]; 
lgd.EdgeColor = [0.5 0.5 0.5];

% Guardar la figura final
set(figPrincipal, 'InvertHardcopy', 'off'); % Mantener el color oscuro al guardar
set(figPrincipal, 'PaperPositionMode', 'auto'); % Respetar la proporción y márgenes en pantalla

nombre_base = 'Combinado_factor50_tauc10k_exclusive';
savefig(figPrincipal, fullfile(carpeta_destino, [nombre_base, '.fig']));
print(figPrincipal, fullfile(carpeta_destino, [nombre_base, '.png']), '-dpng', '-r300');
fprintf('Figura combinada guardada en %s\n', fullfile(carpeta_destino, [nombre_base, '.png']));
