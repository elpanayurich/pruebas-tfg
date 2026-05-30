% test_interpolacion.m
clear; clc; close all;

% 1. CONSTRUIR LA BASE DE DATOS (LUT) CON LOS RESULTADOS OBTENIDOS
% Columnas: [D_AP, N_RIS, tau_c, R_opt]

LUT_data = [
    % Variacion de Area (N_RIS=64, tau_c=10000)
    62.5,  64, 10000, 20;
    125,   64, 10000, 30;
    187.5, 64, 10000, 50;
    250,   64, 10000, 60;
    312.5, 64, 10000, 80;
    375,   64, 10000, 90;
    437.5, 64, 10000, 90;
    500,   64, 10000, 100;
    
    % Variacion de tau_c (D_AP=250, N_RIS=64)
    250, 64, 1000,  0;
    250, 64, 4000,  40;
    250, 64, 7000,  60;
    250, 64, 13000, 70;
    250, 64, 17000, 70;
    250, 64, 20000, 70;
    
    % Variacion de N_RIS (D_AP=250, tau_c=10000)
    250, 4,   10000, 230;
    250, 16,  10000, 150;
    250, 32,  10000, 90;
    250, 128, 10000, 50;
    250, 256, 10000, 30;
];

% Crear el modelo de interpolacion 3D usando los datos
X = LUT_data(:, 1); % D_AP
Y = LUT_data(:, 2); % N_RIS
Z = LUT_data(:, 3); % tau_c
V = LUT_data(:, 4); % R_opt

% scatteredInterpolant crea una funcion de interpolacion
% Usamos 'natural' para interpolacion suave y 'nearest' para extrapolacion
interpolador = scatteredInterpolant(X, Y, Z, V, 'natural', 'nearest');


% 2. DEFINIR ESCENARIOS DE PRUEBA (Distintos a los de la base de datos)
% [tau_c, squareLength, N_RIS]
scenarios = [
    8000,   800, 32;   % Escenario 1
    15000, 1200, 128;  % Escenario 2
];

archivo_salida = 'resultados_interpolacion.txt';
fid = fopen(archivo_salida, 'w');
fprintf(fid, '=================================================================\n');
fprintf(fid, '   PRUEBA DEL ALGORITMO BASADO EN INTERPOLACION (LUT)\n');
fprintf(fid, '=================================================================\n\n');
fclose(fid);

assignment_mode = 'exclusive';
center_grid_factor = 0.5;
nbrOfSetups = 10;
target_cdf = 0.1;

for s_idx = 1:size(scenarios,1)
    tau_c = scenarios(s_idx, 1);
    squareLength = scenarios(s_idx, 2);
    N_RIS = scenarios(s_idx, 3);
    
    D_AP = squareLength / 4;
    
    % --- PREDICCION CON LA TABLA (INTERPOLACION) ---
    R_pred = interpolador(D_AP, N_RIS, tau_c);
    
    % Redondear a la decena más cercana (ya que simulamos en pasos de 10)
    R_lut = round(R_pred / 10) * 10;
    
    fprintf('\n>>> ESCENARIO %d: D_AP=%.1f, N_RIS=%d, tau_c=%d | R_LUT=%d m <<<\n', s_idx, D_AP, N_RIS, tau_c, R_lut);
    
    % Vamos a probar el radio que dice la LUT, y un barrido de -30 a +30 para ver si la LUT acerto
    radios_a_probar = max(0, R_lut-30):10:(R_lut+30);
    
    mejor_radio_sq = -1;
    mejor_se_sq = -Inf;
    se_lut = 0;
    
    for r = radios_a_probar
        RIS_radius = r;
        rng(42); global_seed = 42;
        
        try
            run('main1.m');
            aux = SE_PMMSE_DCC(:,:,1); 
            sorted_se = sort(aux(:));
            se_val = sorted_se(max(1, round(target_cdf * length(sorted_se))));
            
            fprintf('  Radio %3d m -> SE = %.4f bit/s/Hz\n', r, se_val);
            
            if r == R_lut
                se_lut = se_val;
            end
            
            if se_val > mejor_se_sq
                mejor_se_sq = se_val;
                mejor_radio_sq = r;
            end
        catch ME
            fprintf('  [ERROR] Radio %d m: %s\n', r, ME.message);
        end
    end
    
    fid = fopen(archivo_salida, 'a');
    fprintf(fid, 'ESCENARIO %d: tau_c = %d | D_AP = %.1f m | N_RIS = %d\n', s_idx, tau_c, D_AP, N_RIS);
    fprintf(fid, '  Radio Interpolado (LUT): %d m  -> SE = %.4f\n', R_lut, se_lut);
    fprintf(fid, '  Mejor Radio Absoluto:    %d m  -> SE = %.4f\n', mejor_radio_sq, mejor_se_sq);
    fprintf(fid, '  Perdida por usar la LUT: %.2f%%\n', 100 * (1 - (se_lut / mejor_se_sq)));
    fprintf(fid, '-----------------------------------------------------------------\n');
    fclose(fid);
end

fprintf('\nPrueba Finalizada. Resultados guardados en %s\n', archivo_salida);
