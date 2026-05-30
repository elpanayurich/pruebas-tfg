% comparativa_radios_altos.m
clear; clc; close all;

center_grid_factor = 0.5;
nbrOfSetups = 50;
target_cdf = 0.1;
tau_c = 20000;
N_RIS = 64;

% Radios donde estamos seguros de que los círculos de cobertura (>=125m) se solapan
radios_a_probar = 140:10:250;

resultados_inc = zeros(length(radios_a_probar), 1);
resultados_exc = zeros(length(radios_a_probar), 1);

archivo_salida = 'resultados_comparativa_radios_altos.txt';
fid = fopen(archivo_salida, 'w');
fprintf(fid, '=================================================================\n');
fprintf(fid, '   COMPARATIVA: INCLUSIVO vs EXCLUSIVO (Radios 140m - 250m)\n');
fprintf(fid, '   tau_c = 20000, N_RIS = 64, 50 Setups\n');
fprintf(fid, '=================================================================\n\n');
fclose(fid);

for r_idx = 1:length(radios_a_probar)
    r = radios_a_probar(r_idx);
    fprintf('\n>>> EVALUANDO RADIO: %d m <<<\n', r);
    
    % --- MODO EXCLUSIVO ---
    assignment_mode = 'exclusive';
    rng(42); % Semilla fija para comparación justa
    global_seed = 42;
    RIS_radius = r;
    run('main1.m');
    aux = SE_PMMSE_DCC(:,:,1);
    sorted_se = sort(aux(:));
    se_exc = sorted_se(max(1, round(target_cdf * length(sorted_se))));
    
    % --- MODO INCLUSIVO ---
    assignment_mode = 'inclusive';
    rng(42); % Misma semilla
    global_seed = 42;
    RIS_radius = r;
    run('main1.m');
    aux = SE_PMMSE_DCC(:,:,1);
    sorted_se = sort(aux(:));
    se_inc = sorted_se(max(1, round(target_cdf * length(sorted_se))));
    
    resultados_exc(r_idx) = se_exc;
    resultados_inc(r_idx) = se_inc;
    
    fid = fopen(archivo_salida, 'a');
    fprintf(fid, 'Radio %3d m -> EXCLUSIVO: %.4f | INCLUSIVO: %.4f\n', r, se_exc, se_inc);
    fclose(fid);
    fprintf('  Radio %3d m -> EXC: %.4f | INC: %.4f\n', r, se_exc, se_inc);
end

% Guardar figura comparativa
if ~exist('figures_clean', 'dir')
    mkdir('figures_clean');
end

fig = figure('Name', 'Comparativa Inclusivo vs Exclusivo', 'Color', [0.15 0.15 0.15]);
ax = axes(fig); hold on;
plot(ax, radios_a_probar, resultados_exc, '-o', 'LineWidth', 1.5, 'Color', [0.3 0.7 0.9], 'DisplayName', 'Exclusivo (1 RIS - 1 UE)');
plot(ax, radios_a_probar, resultados_inc, '-s', 'LineWidth', 1.5, 'Color', [0.9 0.4 0.4], 'DisplayName', 'Inclusivo (N RIS - 1 UE)');
grid(ax, 'on'); box(ax, 'on');
ax.Color = [0.1 0.1 0.1]; ax.XColor = 'w'; ax.YColor = 'w'; ax.FontSize = 11;
xlabel(ax, 'Radio de conectividad RIS [m]', 'Color', 'w', 'FontWeight', 'bold', 'FontSize', 12);
ylabel(ax, 'Spectral Efficiency (CDF=0.1) [bit/s/Hz]', 'Color', 'w', 'FontWeight', 'bold', 'FontSize', 12);
lgd = legend(ax, 'Location', 'northeast', 'FontSize', 11, 'Box', 'on');
lgd.TextColor = 'w'; lgd.Color = [0.15 0.15 0.15]; lgd.EdgeColor = [0.5 0.5 0.5];

savefig(fig, fullfile('figures_clean', 'Comparativa_Inc_vs_Exc.fig'));
print(fig, fullfile('figures_clean', 'Comparativa_Inc_vs_Exc.png'), '-dpng', '-r300');

fprintf('\nComparativa Finalizada. Gráfica guardada en figures_clean.\n');
