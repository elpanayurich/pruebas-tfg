function risAssignment = assignRIS(probLoS_AP_UE, probLoS_RIS_UE)
    [S, K] = size(probLoS_RIS_UE);
    risAsignadas = zeros(S, 1);        % Vector para saber si una RIS ya ha sido asignada
    %risAssignment = zeros(S, 1);       % Vector final: en la posición s, se guarda el usuario asignado a la RIS s
    usuarioConRIS = zeros(1, K);       % 1 si el usuario ya recibió al menos una RIS

    % Calculo calidad de conexión entre AP y UE
    calidad_AP_UE = sum(probLoS_AP_UE > 0, 1);  % 1xK

    % Ordeno usuarios por menor calidad de conexión
    [~, ordenUsuarios] = sort(calidad_AP_UE);

    for i = 1:K
        k = ordenUsuarios(i);  % Usuario actual

        % Encuentra RIS no asignadas con LoS hacia el usuario k
        ris_candidatos = find(probLoS_RIS_UE(:, k) > 0 & risAsignadas == 0);

        if ~isempty(ris_candidatos)
            for s = ris_candidatos'
                risAsignadas(s) = 1;
                risAssignment{s} = k;             
            end
            usuarioConRIS(k) = 1;
        end

        % Salir si todas las RIS han sido asignadas
        if all(risAsignadas)
            break;
        end
    end

    % Tratamiento de RIS no asignadas
    ris_no_asignadas = find(risAsignadas == 0);
    for s = ris_no_asignadas'
        % Usuarios sin LoS con ningún AP ni ninguna RIS
        sin_AP = calidad_AP_UE == 0;
        sin_RIS = usuarioConRIS == 0;
        candidatos = find(sin_AP & sin_RIS);

        if isempty(candidatos)
            candidatos = find(usuarioConRIS == 0);
        end

        if isempty(candidatos)
            candidatos = 1:K;
        end

        % Elegir un candidato al azar entre los disponibles
        mejor_usuario = candidatos(randi(length(candidatos)));

        risAsignadas(s) = 1;
        risAssignment{s} = mejor_usuario;
        usuarioConRIS(mejor_usuario) = 1; 
    end
end
