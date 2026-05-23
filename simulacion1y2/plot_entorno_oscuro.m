% script para dibujar el entorno con el tema oscuro
clear;
close all;

% Cargar los datos de una de las posiciones (ej: positions1.mat)
load('positions/positions1.mat');

xAP = real(APpositions(:));
yAP = imag(APpositions(:));
xRIS = real(RISpositions(:));
yRIS = imag(RISpositions(:));
xUE = real(UEpositions(:));
yUE = imag(UEpositions(:));

% 3. Crear figura con FONDO OSCURO
figPrincipal = figure('Name', 'Entorno Grid', 'Color', [0.15 0.15 0.15]); 
axPrincipal = axes(figPrincipal); 
hold(axPrincipal, 'on'); 

% Dibujar elementos con colores que destaquen sobre fondo oscuro
hAP = scatter(axPrincipal, xAP, yAP, 100, '^', 'filled', 'MarkerFaceColor', [0.3 0.8 1], 'MarkerEdgeColor', 'w'); % Azul claro
hRIS = scatter(axPrincipal, xRIS, yRIS, 100, 's', 'filled', 'MarkerFaceColor', [0.2 0.8 0.2], 'MarkerEdgeColor', 'w'); % Verde brillante
hUE = scatter(axPrincipal, xUE, yUE, 60, 'o', 'filled', 'MarkerFaceColor', [1 0.4 0.4], 'MarkerEdgeColor', 'w'); % Rojo salmón

% 5. Formato del gráfico adaptado a TEMA OSCURO (UNIFICADO)
grid(axPrincipal, 'on');
box(axPrincipal, 'on');
axPrincipal.Color = [0.1 0.1 0.1]; 
axPrincipal.XColor = 'w'; 
axPrincipal.YColor = 'w'; 
axPrincipal.FontSize = 11;
axPrincipal.GridAlpha = 0.3; 
xlabel(axPrincipal, 'x [m]', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'w');
ylabel(axPrincipal, 'y [m]', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'w');

% Ajuste para proporciones iguales (sin deformar el mapa)
axis(axPrincipal, 'equal');

% Leyenda estilo "Cuadrado Pro" con recuadro integrado
lgd = legend(axPrincipal, [hAP, hRIS, hUE], {'AP', 'RIS', 'UE'}, 'Location', 'best', 'FontSize', 11, 'Box', 'on');
lgd.TextColor = 'w';
lgd.Color = [0.15 0.15 0.15]; 
lgd.EdgeColor = [0.5 0.5 0.5];

% Ajustar márgenes explícitamente (Igual que los otros: Izquierdo: 0.065, Derecho: 0.065, Arriba: 0.078, Abajo: 0.078)
% Nota: Al usar 'axis equal', MATLAB restringe la caja para mantener proporción 1:1, 
% pero forzamos la posición exterior para asegurar simetría en la exportación.
axPrincipal.Position = [0.065, 0.078, 0.87, 0.844];

% 6. Guardar la figura final respetando el tema oscuro y los márgenes
set(figPrincipal, 'InvertHardcopy', 'off'); % Mantener el color oscuro
set(figPrincipal, 'PaperPositionMode', 'auto'); % Respetar márgenes de pantalla

savefig(figPrincipal, fullfile('positions', 'entorno_grid_oscuro.fig'));
print(figPrincipal, fullfile('positions', 'entorno_grid_oscuro.png'), '-dpng', '-r300');
fprintf('Figura guardada: positions/entorno_grid_oscuro.png\n');
