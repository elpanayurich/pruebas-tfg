% plot_radio_optimo_atomos.m - Radio Óptimo vs N_RIS con barras de error en rojo

% 1. Definir los datos
N_RIS = [4, 16, 32, 64, 128, 256];
radioOptimo = [220, 140, 80, 70, 50, 30];

% Definir el margen de error (10 metros para todos los puntos)
errorMargin = 10 * ones(1, length(N_RIS));

% 2. Configuración visual base
colorLinea = lines(1); 
colorError = [0.85 0.3 0.3]; % Un rojo suave que queda muy bien en temas oscuros

% 3. Crear figura con FONDO OSCURO y definir EJES EXPLÍCITOS
figPrincipal = figure('Name', 'Radio Optimo vs Cantidad de Atomos', 'Color', [0.15 0.15 0.15]); 
axPrincipal = axes(figPrincipal); 
hold(axPrincipal, 'on'); 

% 4. Graficar PRIMERO las barras de error en ROJO (sin línea principal)
errorbar(axPrincipal, N_RIS, radioOptimo, errorMargin, ...
    'Color', colorError, ...
    'LineStyle', 'none', ...  
    'LineWidth', 1.2, ...       
    'Marker', 'none', ...
    'CapSize', 8, ... 
    'HandleVisibility', 'off'); 

% 5. Graficar DESPUÉS la línea y los marcadores en el color base
plot(axPrincipal, N_RIS, radioOptimo, ...
    'Color', colorLinea(1, :), ...
    'LineStyle', '-', ...
    'Marker', 'o', ...
    'LineWidth', 1.5, ...       
    'MarkerSize', 7, ...
    'MarkerFaceColor', [0.15 0.15 0.15], ... 
    'DisplayName', 'Radio Óptimo estimado (\pm 10 m)');

hold(axPrincipal, 'off');

% 6. Formato del gráfico adaptado a TEMA OSCURO (UNIFICADO)
grid(axPrincipal, 'on');
box(axPrincipal, 'on');
axPrincipal.Color = [0.1 0.1 0.1]; 
axPrincipal.XColor = 'w'; 
axPrincipal.YColor = 'w'; 
axPrincipal.FontSize = 11;
axPrincipal.GridAlpha = 0.3; 

% Etiquetas de los ejes
xlabel(axPrincipal, 'Cantidad de Átomos (N_{RIS})', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'w');
ylabel(axPrincipal, 'Radio óptimo de conectividad [m]', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'w');

% Ajustar márgenes explícitamente
axPrincipal.Position = [0.065, 0.078, 0.87, 0.844];

% Modificar los "ticks" (marcas) del eje X para que coincidan con tus datos exactos
xticks(axPrincipal, N_RIS);

% Leyenda estilo "Cuadrado Pro" ABAJO A LA DERECHA ('northeast')
lgd = legend(axPrincipal, 'Location', 'northeast', 'FontSize', 11, 'Box', 'on');
lgd.TextColor = 'w';
lgd.Color = [0.15 0.15 0.15]; 
lgd.EdgeColor = [0.5 0.5 0.5];

% 7. Guardar la figura final
if ~exist('figures_clean', 'dir')
    mkdir('figures_clean');
end

set(figPrincipal, 'InvertHardcopy', 'off'); 
set(figPrincipal, 'PaperPositionMode', 'auto'); 

% Guardado en .fig y .png
savefig(figPrincipal, fullfile('figures_clean', 'RadioOptimo_vs_Atomos_ErrorRojo.fig'));
print(figPrincipal, fullfile('figures_clean', 'RadioOptimo_vs_Atomos_ErrorRojo.png'), '-dpng', '-r300');

fprintf('Figura combinada guardada en figures_clean/RadioOptimo_vs_Atomos_ErrorRojo.fig y .png\n');