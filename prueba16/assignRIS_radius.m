function [RISassignment, tau_p] = assignRIS_radius(file_index, max_dist, ap_dist, N_RIS, K, L, S)
   
    num_ap = L;
    num_ris = S;
    
    % Initialize outputs for a single file
    RISassignment = cell(num_ris, 1);
    assigned_count = 0;
    unassigned_count = 0;
    
    filename = sprintf('positions/positions%d.mat', file_index);
    
    if ~exist(filename, 'file')
        error('File %s not found.', filename);
    end
    
    data = load(filename);
    
    % 1. Filter out users within the AP "No-RIS" zone
    if isfield(data, 'dist_AP_UE')
        dist_matrix_AP = data.dist_AP_UE;
        dist_matrix_RIS = data.dist_RIS_UE;
        
        [min_vals_AP, assigned_users_AP] = min(dist_matrix_AP, [], 2);
        
        for ap_idx = 1:num_ap
            if min_vals_AP(ap_idx) < ap_dist
                target_user = assigned_users_AP(ap_idx);
                dist_matrix_RIS(:, target_user) = 10000;
            end
        end
    else
        error('Variable "dist_AP_UE" not found in %s', filename);
    end
    
    % 2. Assign remaining users to RISs based on closest distance
    if isfield(data, 'dist_RIS_UE')
        [min_vals_RIS, assigned_users_RIS] = min(dist_matrix_RIS, [], 2);
        
        for ris_idx = 1:num_ris
            if min_vals_RIS(ris_idx) > max_dist
                RISassignment{ris_idx} = [];
                unassigned_count = unassigned_count + 1;
            else
                RISassignment{ris_idx} = assigned_users_RIS(ris_idx);
                assigned_count = assigned_count + 1;
            end
        end
        
    else
        error('Variable "dist_RIS_UE" not found in %s', filename);
    end

    tau_p = 0; 
    for i = 1:assigned_count
        tau_p = tau_p + sum(1 * (1 + N_RIS));
    end
    tau_p = tau_p + K;

    fprintf('Processed: %s (Assigned: %d, Unassigned: %d, tau_p: %d)\n', filename, assigned_count, unassigned_count, tau_p);
end