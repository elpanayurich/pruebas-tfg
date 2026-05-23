% 1. Definir la carpeta, archivos y etiquetas
carpeta = 'results/'; 
archivos = {'all-assigned.fig', 'no-assignment.fig', 'no-ris.fig', 'random-assignment.fig'};
etiquetas = {'Todas Asignadas', 'Sin Asignación', 'Sin RIS', 'Asignación Aleatoria'};

% 2. Configuración visual
colores = lines(4); 
estilosLinea = {'-', '--', ':', '-.'}; 
marcadores = {'o', 's', '^', 'd'};     

% 3. Crear figura con FONDO OSCURO y definir EJES EXPLÍCITOS
figPrincipal = figure('Name', 'Resultados Setup Grid', 'Color', [0.15 0.15 0.15]); 
axPrincipal = axes(figPrincipal); 
hold(axPrincipal, 'on'); 
hLineas = zeros(1, 4);

% 4. Bucle para procesar
for i = 1:length(archivos)
    rutaCompleta = fullfile(carpeta, archivos{i});
    figTemp = openfig(rutaCompleta, 'invisible');
    
    axTemp = gca(figTemp);
    objLinea = findobj(axTemp, 'Type', 'line'); 
    
    xData = get(objLinea(1), 'XData');
    yData = get(objLinea(1), 'YData');
    
    saltoMarcador = max(1, round(length(xData) / 15)); 
    
    hLineas(i) = plot(axPrincipal, xData, yData, ...
        'Color', colores(i, :), ...
        'LineStyle', estilosLinea{i}, ...
        'Marker', marcadores{i}, ...
        'MarkerIndices', 1:saltoMarcador:length(xData), ... 
        'LineWidth', 1.5, ...       
        'MarkerSize', 7, ...        
        'DisplayName', etiquetas{i});
    
    close(figTemp);
end
hold(axPrincipal, 'off');

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

% Leyenda estilo "Cuadrado Pro" con recuadro integrado
lgd = legend(axPrincipal, hLineas, 'Location', 'best', 'FontSize', 11, 'Box', 'on');
lgd.TextColor = 'w';
lgd.Color = [0.15 0.15 0.15]; 
lgd.EdgeColor = [0.5 0.5 0.5];

% 6. Guardar la figura final respetando el tema oscuro y los márgenes
set(figPrincipal, 'InvertHardcopy', 'off'); % Mantener el color oscuro
set(figPrincipal, 'PaperPositionMode', 'auto'); % Respetar márgenes de pantalla

if ~exist('results', 'dir')
    mkdir('results');
end

savefig(figPrincipal, fullfile('results', 'NoRIS_vs_RIS_grid.fig'));
print(figPrincipal, fullfile('results', 'NoRIS_vs_RIS_grid.png'), '-dpng', '-r300');
fprintf('Figura guardada: NoRIS_vs_RIS_grid.png\n');