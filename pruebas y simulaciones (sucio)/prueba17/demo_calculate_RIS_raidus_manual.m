% Carga una de tus posiciones, elige el porcentaje de usuarios a los que 
% quieres dar prioridad lanza el script, saldrá como resultado 
% el radio de conectividad de las RISs para usar en ese escenario además
% de informarte del factor de descentrado calculado de tu setup

user_percentage = 0.5;  % Entre 0.1 y 0.9

L = size(APpositions, 1);
squareLength = real(max(RISpositions));

center_grid_factor = calculate_center_grid_factor(APpositions, L, squareLength);
RIS_radius = calculate_RIS_settings(center_grid_factor, user_percentage);

fprintf('Factor de descentrado: %.4f\n', center_grid_factor);
fprintf('Radio de conectividad RIS sugerido: %.2f m\n', RIS_radius);