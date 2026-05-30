% dual_seed_optimization.m
clear; clc; close all;

semillas = [42, 999]; % Dos escenarios globales totalmente distintos
target_cdf = 0.1;

for i = 1:length(semillas)
    global_seed = semillas(i);
    fprintf('\n\n**************************************************************\n');
    fprintf('   INICIANDO OPTIMIZACION CON SEMILLA GLOBAL: %d\n', global_seed);
    fprintf('**************************************************************\n');
    
    a = 55; b = 80; tol = 2; phi = (sqrt(5) - 1) / 2;
    c = b - phi * (b - a); d = a + phi * (b - a);
    
    % Eval C
    r_c = round(c);
    rng(global_seed); % Reset state so main1 generates exact same scenarios
    RIS_radius = r_c;
    assignment_mode = 'exclusive';
    center_grid_factor = 0.5;
    squareLength = 1000;
    nbrOfSetups = 50; 
    run('main1.m');
    aux = SE_PMMSE_DCC(:,:,1); sorted_se = sort(aux(:));
    fc = sorted_se(max(1, round(target_cdf * length(sorted_se))));
    fprintf('--- SE en %d m = %.4f bit/s/Hz ---\n', r_c, fc);
    
    % Eval D
    r_d = round(d);
    rng(global_seed); 
    RIS_radius = r_d;
    assignment_mode = 'exclusive'; center_grid_factor = 0.5; squareLength = 1000; nbrOfSetups = 50; 
    run('main1.m');
    aux = SE_PMMSE_DCC(:,:,1); sorted_se = sort(aux(:));
    fd = sorted_se(max(1, round(target_cdf * length(sorted_se))));
    fprintf('--- SE en %d m = %.4f bit/s/Hz ---\n', r_d, fd);
    
    iter = 1;
    while abs(b - a) > tol
        fprintf('\n>> Iter %d | Rango: [%.1f, %.1f]\n', iter, a, b);
        if fc > fd
            b = d; d = c; fd = fc;
            c = b - phi * (b - a); r_c = round(c);
            rng(global_seed); RIS_radius = r_c; assignment_mode = 'exclusive'; center_grid_factor = 0.5; squareLength = 1000; nbrOfSetups = 50; 
            run('main1.m');
            aux = SE_PMMSE_DCC(:,:,1); sorted_se = sort(aux(:));
            fc = sorted_se(max(1, round(target_cdf * length(sorted_se))));
            fprintf('--- SE en %d m = %.4f bit/s/Hz ---\n', r_c, fc);
        else
            a = c; c = d; fc = fd;
            d = a + phi * (b - a); r_d = round(d);
            rng(global_seed); RIS_radius = r_d; assignment_mode = 'exclusive'; center_grid_factor = 0.5; squareLength = 1000; nbrOfSetups = 50; 
            run('main1.m');
            aux = SE_PMMSE_DCC(:,:,1); sorted_se = sort(aux(:));
            fd = sorted_se(max(1, round(target_cdf * length(sorted_se))));
            fprintf('--- SE en %d m = %.4f bit/s/Hz ---\n', r_d, fd);
        end
        iter = iter + 1;
    end
    optimo = round((a + b) / 2);
    fprintf('\n=> OPTIMO PARA SEMILLA %d: %d metros\n', global_seed, optimo);
end
