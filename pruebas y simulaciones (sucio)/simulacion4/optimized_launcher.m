% optimized_launcher.m - Búsqueda Inteligente del Radio Óptimo (Golden Section)
clear; clc; close all;

% Configuracion base para main1.m
assignment_mode = 'exclusive';
center_grid_factor = 0.5;
squareLength = 1000;
nbrOfSetups = 50; % Aumentamos a 50 setups para mayor precision estadistica
target_cdf = 0.1;

% Parametros de la Búsqueda de la Sección Dorada
a = 55;   % Limite inferior del radio a explorar
b = 75;   % Limite superior del radio a explorar
tol = 2;  % Tolerancia (detener cuando el rango sea menor o igual a 2 metros)
phi = (sqrt(5) - 1) / 2; % Proporción áurea (~0.618)

% Calculamos los dos puntos interiores iniciales
c = b - phi * (b - a);
d = a + phi * (b - a);

fprintf('=================================================================\n');
fprintf('   INICIANDO BUSQUEDA INTELIGENTE DEL RADIO OPTIMO (SECCION DORADA)   \n');
fprintf('=================================================================\n');
fprintf('Rango de busqueda: [%.1f, %.1f] metros\n', a, b);
fprintf('Setups por iteracion: %d\n', nbrOfSetups);

% --- EVALUAR EN C ---
r_c = round(c);
fprintf('\n>>> Evaluando punto interno C = %d metros...\n', r_c);
RIS_radius = r_c;
run('main1.m');
aux = SE_PMMSE_DCC(:,:,1); 
sorted_se = sort(aux(:));
idx = max(1, round(target_cdf * length(sorted_se)));
fc = sorted_se(idx);
fprintf('--- RESULTADO C: SE en %d m = %.4f bit/s/Hz ---\n', r_c, fc);

% --- EVALUAR EN D ---
r_d = round(d);
fprintf('\n>>> Evaluando punto interno D = %d metros...\n', r_d);
RIS_radius = r_d;
run('main1.m');
aux = SE_PMMSE_DCC(:,:,1);
sorted_se = sort(aux(:));
idx = max(1, round(target_cdf * length(sorted_se)));
fd = sorted_se(idx);
fprintf('--- RESULTADO D: SE en %d m = %.4f bit/s/Hz ---\n', r_d, fd);

iter = 1;
while abs(b - a) > tol
    fprintf('\n=================================================================\n');
    fprintf('ITERACION %d | Rango actual: [%.1f, %.1f]\n', iter, a, b);
    
    if fc > fd
        % El óptimo debe estar entre [a, d]
        b = d;
        d = c;
        fd = fc; % Reciclamos el calculo que ya teniamos
        
        % Calculamos el nuevo punto C
        c = b - phi * (b - a);
        r_c = round(c);
        
        fprintf('>>> El optimo esta a la izquierda. Evaluando nuevo C = %d metros...\n', r_c);
        RIS_radius = r_c;
        run('main1.m');
        aux = SE_PMMSE_DCC(:,:,1);
        sorted_se = sort(aux(:));
        idx = max(1, round(target_cdf * length(sorted_se)));
        fc = sorted_se(idx);
        fprintf('--- RESULTADO C: SE en %d m = %.4f bit/s/Hz ---\n', r_c, fc);
        
    else
        % El óptimo debe estar entre [c, b]
        a = c;
        c = d;
        fc = fd; % Reciclamos el calculo que ya teniamos
        
        % Calculamos el nuevo punto D
        d = a + phi * (b - a);
        r_d = round(d);
        
        fprintf('>>> El optimo esta a la derecha. Evaluando nuevo D = %d metros...\n', r_d);
        RIS_radius = r_d;
        run('main1.m');
        aux = SE_PMMSE_DCC(:,:,1);
        sorted_se = sort(aux(:));
        idx = max(1, round(target_cdf * length(sorted_se)));
        fd = sorted_se(idx);
        fprintf('--- RESULTADO D: SE en %d m = %.4f bit/s/Hz ---\n', r_d, fd);
    end
    iter = iter + 1;
end

optimo = round((a + b) / 2);
fprintf('\n=================================================================\n');
fprintf('                 BUSQUEDA INTELIGENTE FINALIZADA                   \n');
fprintf('=================================================================\n');
fprintf('El rango final es [%.1f, %.1f].\n', a, b);
fprintf('=> RADIO OPTIMO ESTIMADO (con 50 setups): %d metros\n', optimo);
fprintf('=================================================================\n');