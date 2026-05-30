function [RISassignment, tau_p] = assignRIS_radius_exclusive(file_index, max_dist, ap_dist, N_RIS, K, L, S)
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
                dist_matrix_RIS(:, target_user) = 10000; % Prevent assignment to this user
            end
        end
    else
        error('Variable "dist_AP_UE" not found in %s', filename);
    end
    
    % 2. Assign remaining users to RISs based on closest distance EXCLUSIVELY
    if isfield(data, 'dist_RIS_UE')
        % In this exclusive mode, a user can be assigned to at most 1 RIS (the closest one).
        % We iterate to find the closest (RIS, UE) pairs greedily or simply assign 
        % each user to their closest RIS if within max_dist. However, the original function
        % only allowed 1 UE per RIS. To keep that behavior (1 UE per RIS, 1 RIS per UE),
        % we can assign each user to its closest RIS, and if multiple users prefer the same RIS,
        % the RIS takes the closest user.
        
        % Original code did:
        % [min_vals_RIS, assigned_users_RIS] = min(dist_matrix_RIS, [], 2);
        % This finds the closest UE for each RIS.
        
        % Now we want to ensure no UE is assigned to multiple RISs.
        % We can keep track of assigned UEs.
        
        % Sort all (RIS, UE) distances
        dist_flat = dist_matrix_RIS(:);
        [sorted_dists, sorted_indices] = sort(dist_flat);
        
        assigned_ues = false(1, K);
        assigned_ris = false(1, num_ris);
        
        for i = 1:length(sorted_indices)
            dist = sorted_dists(i);
            
            % Stop if the remaining distances are greater than max_dist
            if dist > max_dist
                break;
            end
            
            % Convert 1D index back to 2D subscripts (RIS_idx, UE_idx)
            [ris_idx, ue_idx] = ind2sub(size(dist_matrix_RIS), sorted_indices(i));
            
            % If neither the RIS nor the UE is assigned yet, make the assignment
            if ~assigned_ris(ris_idx) && ~assigned_ues(ue_idx)
                RISassignment{ris_idx} = ue_idx;
                assigned_ris(ris_idx) = true;
                assigned_ues(ue_idx) = true;
                assigned_count = assigned_count + 1;
            end
            
            % If all RISs are assigned, we can stop early
            if all(assigned_ris)
                break;
            end
        end
        
        % Count unassigned RISs
        unassigned_count = num_ris - assigned_count;
        
    else
        error('Variable "dist_RIS_UE" not found in %s', filename);
    end

    tau_p = 0; 
    for i = 1:assigned_count
        tau_p = tau_p + sum(1 * (1 + N_RIS));
    end
    tau_p = tau_p + K;

    fprintf('Processed: %s (Assigned: %d, Unassigned: %d, tau_p: %d) [EXCLUSIVE]\n', filename, assigned_count, unassigned_count, tau_p);
end