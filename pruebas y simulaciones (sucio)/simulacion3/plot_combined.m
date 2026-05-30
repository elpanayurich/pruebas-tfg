% plot_combined.m - Script to combine individual CDF figures with a dark theme

% 1. Definir la carpeta, archivos y etiquetas
carpeta = 'figures_clean/'; 
archivos = {
    'all.fig', ...
    'random_2.fig', ...
    'random_1.fig', ...
    'closest_2.fig', ...
    'closest_1.fig', ...
    'no_assignment.fig', ...
    'closest_K_unassigned.fig'
};

% Leyendas más autoexplicativas
etiquetas = {
    'Todas las RIS asignadas a Todos los Usuarios', ...
    'Todas las RIS asignadas a 2 Usuarios Aleatorios', ...
    'Todas las RIS asignadas a 1 Usuario Aleatorio', ...
    'Todas las RIS asignadas a los 2 Usuarios Más Cercanos', ...
    'Todas las RIS asignadas al Usuario Más Cercano', ...
    'Sin Asignación de RIS (Configuración Aleatoria/Base)', ...
    'K RIS asignadas a su Usuario Más Cercano (1 RIS por UE)'
};

% 2. Configuración visual base
coloresBase = lines(7); 
estilosLinea = {'-', '--', ':', '-.', '-', '--', '-.'}; 
marcadores = {'o', 's', '^', 'd', 'v', 'p', 'h'};     

% 3. Crear figura con FONDO OSCURO y definir EJES EXPLÍCITOS
figPrincipal = figure('Name', 'Resultados Combinados', 'Color', [0.15 0.15 0.15]); 
axPrincipal = axes(figPrincipal); 
hold(axPrincipal, 'on'); 
hLineas = zeros(1, length(archivos));

% 4. Bucle para procesar las curvas
for i = 1:length(archivos)
    rutaCompleta = fullfile(carpeta, archivos{i});
    if ~exist(rutaCompleta, 'file')
        warning('No se encontro el archivo: %s. Saltando...', rutaCompleta);
        continue;
    end
    
    figTemp = openfig(rutaCompleta, 'invisible');
    
    axTemp = gca(figTemp);
    objLinea = findobj(axTemp, 'Type', 'line'); 
    
    xData = get(objLinea(1), 'XData');
    yData = get(objLinea(1), 'YData');
    
    saltoMarcador = max(1, round(length(xData) / 15)); 
    
    hLineas(i) = plot(axPrincipal, xData, yData, ...
        'Color', coloresBase(i, :), ...
        'LineStyle', estilosLinea{i}, ...
        'Marker', marcadores{i}, ...
        'MarkerIndices', 1:saltoMarcador:length(xData), ... 
        'LineWidth', 1.5, ...       
        'MarkerSize', 7, ...        
        'DisplayName', etiquetas{i});
    
    close(figTemp);
end
hold(axPrincipal, 'off');

% Quitar líneas nulas (en caso de que algún archivo no existiera)
hLineas = hLineas(hLineas ~= 0);

% 5. Formato del gráfico adaptado a TEMA OSCURO (UNIFICADO)
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

% Leyenda estilo "Cuadrado Pro" con recuadro integrado y autoexplicativa
lgd = legend(axPrincipal, hLineas, 'Location', 'best', 'FontSize', 11, 'Box', 'on');
lgd.TextColor = 'w';
lgd.Color = [0.15 0.15 0.15]; 
lgd.EdgeColor = [0.5 0.5 0.5];

% Guardar la figura final
set(figPrincipal, 'InvertHardcopy', 'off'); % Mantener el color oscuro al guardar
set(figPrincipal, 'PaperPositionMode', 'auto'); % Respetar la proporción y márgenes en pantalla

savefig(figPrincipal, fullfile('figures_clean', 'RIS_Assignment_Strategies.fig'));
% Usar print en lugar de saveas/exportgraphics para mantener los márgenes de la ventana
print(figPrincipal, fullfile('figures_clean', 'RIS_Assignment_Strategies.png'), '-dpng', '-r300');
fprintf('Figura combinada guardada en figures_clean/RIS_Assignment_Strategies.fig y .png\n');