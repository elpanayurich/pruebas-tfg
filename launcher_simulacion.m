% launcher_simulacion.m
% Script diseñado para que el usuario pueda lanzar una simulación de un 
% escenario concreto, eligiendo libremente el modo de asignación de RIS.

clear; clc; close all;

fprintf('========================================================\n');
fprintf('       LANZADOR DE SIMULACION (Un solo escenario)\n');
fprintf('========================================================\n');

% =========================================================================
% 1. PARAMETROS DEL ESCENARIO (Modifica estos valores para tu prueba)
% =========================================================================
tau_c = 10000;          % Longitud del bloque de coherencia
squareLength = 1000;    % Tamaño del area de cobertura (ej. 1000m x 1000m)
N_RIS = 64;             % Numero de metaatomos por RIS
L = 16;                 % Numero de APs
K = 15;                 % Numero de UEs

% =========================================================================
% 2. MODO DE ASIGNACION DE RIS
% =========================================================================
% Elige entre:
% - 'inclusive': Múltiples RIS pueden compartir al mismo usuario (requiere RIS_radius).
% - 'exclusive': Asignación 1 a 1 estricta, 1 RIS atiende máximo a 1 Usuario (requiere RIS_radius).
% - 'final'    : Aplica el Algoritmo Final con cálculo automático del radio óptimo interno (ignora RIS_radius).
assignment_mode = 'final'; 

% Si has elegido 'inclusive' o 'exclusive', define aquí el radio a usar:
RIS_radius = 60; 

% =========================================================================
% 3. CONFIGURACION ADICIONAL
% =========================================================================
center_grid_factor = 0.5;
nbrOfSetups = 10; % Cuantos más, más precisa la media, pero más tarda.
target_cdf = 0.1;

fprintf(' Parametros:\n');
fprintf(' - tau_c: %d\n', tau_c);
fprintf(' - Area: %d m\n', squareLength);
fprintf(' - N_RIS: %d\n', N_RIS);
fprintf(' - Modo de Asignacion: %s\n', upper(assignment_mode));
if ~strcmp(assignment_mode, 'final')
    fprintf(' - Radio Manual (RIS_radius): %d m\n', RIS_radius);
end
fprintf(' Iniciando simulacion...\n\n');

% Fijar semilla para repetibilidad
rng(123); global_seed = 123;

% =========================================================================
% 4. EJECUCION DE LA SIMULACION
% =========================================================================
try
    % Llama al script principal, que leerá las variables de este workspace
    run('main1.m');
    
    % Extraer el valor de Eficiencia Espectral (SE) al 10% de CDF
    aux = SE_PMMSE_DCC(:,:,1);
    sorted_se = sort(aux(:));
    se_val = sorted_se(max(1, round(target_cdf * length(sorted_se))));
    
    fprintf('\n========================================================\n');
    fprintf('SIMULACION FINALIZADA CON EXITO\n');
    fprintf('-> Eficiencia Espectral (10%% CDF): %.4f bit/s/Hz\n', se_val);
    fprintf('-> La grafica CDF se ha guardado automaticamente en la carpeta /figures\n');
    fprintf('========================================================\n');

catch ME
    fprintf('\n[ERROR] La simulacion ha fallado: %s\n', ME.message);
end