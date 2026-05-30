function R = Rlocalscattering(M,angle,ASDdeg,antennaSpacing)
% Genera la matriz de correlación espacial para un canal con dispersión local.
%
% Entradas:
%   M             : Número de antenas.
%   angle         : Ángulo de llegada de la señal (en radianes).
%   ASDdeg        : Desviación estándar angular (Angular Standard Deviation) en grados.
%   antennaSpacing: Espaciado entre antenas (en longitudes de onda).
%
% Salidas:
%   R             : Matriz de correlación espacial (M x M).
%
% Notas:
%   - La matriz de correlación se calcula utilizando un modelo de dispersión
%     local gaussiano.
%   - El ángulo de llegada y la desviación estándar angular determinan la
%     correlación entre las señales recibidas en diferentes antenas.
%   - El espaciado entre antenas afecta la fase de la correlación.
%
% Variables locales:
%   ASD         : Desviación estándar angular en radianes.
%   diff_angles : Diferencia de ángulos entre cada par de antenas.
%   R_temp        : Matriz de correlación temporal.
%ASD = ASDdeg * pi / 180; % Convertir ASD de grados a radianes
ASD = ASDdeg;
diff_angles = repmat(0:(M-1), M, 1) - repmat((0:(M-1))', 1, M);
R = exp(-((pi * antennaSpacing * diff_angles * sin(angle)).^2) / (2 * ASD^2));
% Rotate the correlation matrix according to the nominal angle of departure
varphi = (0:M-1)'*2*pi*antennaSpacing*sin(angle);
rotationVector = exp(1i*varphi);
R = rotationVector*rotationVector'.*R;
end