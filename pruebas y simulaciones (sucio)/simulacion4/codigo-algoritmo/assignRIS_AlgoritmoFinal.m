function [RISassignment, tau_p] = assignRIS_AlgoritmoFinal(file_index, ap_dist, N_RIS, K, L, S, tau_c, squareLength)
    % assignRIS_AlgoritmoFinal.m
    %
    % Algoritmo de asignacion empirica definitivo (Ecuacion unificada TFG).
    % Calcula el radio R_opt internamente en funcion de los parametros de la
    % red y efectua la asignacion exclusiva de las RIS (max 1 por UE).
    
    num_ap = L;
    num_ris = S;
    RISassignment = cell(num_ris, 1);
    assigned_count = 0;
    
    % =====================================================================
    % 1. CALCULO DEL RADIO OPTIMO (Ecuacion del TFG)
    % =====================================================================
    APperdim = sqrt(L);
    D_AP = squareLength / APperdim;
    R_opt = (0.25 * D_AP) * sqrt((64 / N_RIS) * (tau_c / 10000));
    
    % =====================================================================
    % 2. CARGA DE POSICIONES
    % =====================================================================
    filename = sprintf('positions/positions%d.mat', file_index);
    if ~exist(filename, 'file')
        % Comprobar si se esta ejecutando desde una subcarpeta
        filename = sprintf('../positions/positions%d.mat', file_index);
        if ~exist(filename, 'file')
            error('Archivo de posiciones no encontrado: %s', filename);
        end
    end
    
    data = load(filename);
    dist_matrix_AP = data.dist_AP_UE;
    dist_matrix_RIS = data.dist_RIS_UE;
    
    % =====================================================================
    % 3. FILTRADO DE USUARIOS CON LOS DIRECTO (Muy cerca del AP)
    % =====================================================================
    [min_vals_AP, assigned_users_AP] = min(dist_matrix_AP, [], 2);
    for ap_idx = 1:num_ap
        if min_vals_AP(ap_idx) < ap_dist
            target_user = assigned_users_AP(ap_idx);
            % Aislamos a este usuario para que no consuma recursos de RIS
            dist_matrix_RIS(:, target_user) = 10000; 
        end
    end
    
    % =====================================================================
    % 4. ASIGNACION EXCLUSIVA (1 a 1) USANDO R_opt
    % =====================================================================
    % Ordenar todas las distancias RIS-UE de menor a mayor
    dist_flat = dist_matrix_RIS(:);
    [sorted_dists, sorted_indices] = sort(dist_flat);
    
    assigned_ues = false(1, K);
    assigned_ris = false(1, num_ris);
    
    for i = 1:length(sorted_indices)
        dist = sorted_dists(i);
        
        % Si la distancia supera nuestro radio optimo calculado, paramos
        if dist > R_opt
            break; 
        end
        
        % Recuperar los indices de RIS y Usuario
        [ris_idx, ue_idx] = ind2sub(size(dist_matrix_RIS), sorted_indices(i));
        
        % Si ni la RIS ni el Usuario han sido asignados todavia, emparejamos
        if ~assigned_ris(ris_idx) && ~assigned_ues(ue_idx)
            RISassignment{ris_idx} = ue_idx;
            assigned_ris(ris_idx) = true;
            assigned_ues(ue_idx) = true;
            assigned_count = assigned_count + 1;
        end
        
        % Si todas las RIS ya estan ocupadas, terminamos
        if all(assigned_ris)
            break;
        end
    end
    
    % =====================================================================
    % 5. CALCULO DEL COSTE DE PILOTOS
    % =====================================================================
    tau_p = assigned_count * (1 + N_RIS) + K;
    
    % (Opcional) Descomentar para debug en consola
    % fprintf('Algoritmo Final TFG | R_opt: %.1fm | RIS asignadas: %d | tau_p: %d\n', R_opt, assigned_count, tau_p);
end