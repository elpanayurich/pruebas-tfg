function risAssignment = assignRIS_All(probLoS_AP_UE, probLoS_RIS_UE)
    % assignRIS_All Asigna todas las RIS a todos los usuarios.
    %
    % Entradas:
    %   probLoS_AP_UE  : Probabilidad de LoS AP-UE (no usado aqui, pero mantenido por compatibilidad)
    %   probLoS_RIS_UE : Probabilidad de LoS RIS-UE (S x K)
    %
    % Salida:
    %   risAssignment  : Cell array de tamaño (S x 1).
    %                    risAssignment{s} contiene un vector [1, 2, ..., K]
    %                    indicando que la RIS s sirve a todos los usuarios.

    [S, K] = size(probLoS_RIS_UE);
    
    risAssignment = cell(S, 1);
    
    allUsers = 1:K;
    
    for s = 1:S
        risAssignment{s} = allUsers;
    end

end
