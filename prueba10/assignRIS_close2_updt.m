function risAssignment = assignRIS_close2_updt(dist_RIS_UE, UEpositions)
    % assignRIS_close2_updt Assigns RIS to the nearest user, and potentially a neighbor.
    % Logic:
    % 1. Find the nearest user to the RIS (User A).
    % 2. Check if there are other users within 20m of User A.
    % 3. If yes, assign RIS to User A and the closest neighbor (User B).
    % 4. If no, assign RIS only to User A.
    %
    % Input:
    %   dist_RIS_UE: Matrix (S x K) of distances between RIS and UEs.
    %   UEpositions: Vector (K x 1) of user positions (complex numbers).
    % Output:
    %   risAssignment: Cell array (1 x S) where each element is a vector of user indices.

    [S, K] = size(dist_RIS_UE);
    risAssignment = cell(1, S);
    threshold_distance = 20; % meters

    for s = 1:S
        % 1. Find nearest user to RIS s
        [~, u_near_idx] = min(dist_RIS_UE(s, :));
        u_near_pos = UEpositions(u_near_idx);
        
        % 2. Calculate distances from u_near to all other users
        % UEpositions is likely complex (x + iy)
        dist_from_u_near = abs(UEpositions - u_near_pos);
        
        % Exclude the user itself (distance 0) by setting it to infinity temporarily
        dist_from_u_near(u_near_idx) = inf;
        
        % 3. Find neighbors within threshold
        [min_neighbor_dist, neighbor_idx] = min(dist_from_u_near);
        
        if min_neighbor_dist <= threshold_distance
            % Found a neighbor within 20m
            risAssignment{s} = [u_near_idx, neighbor_idx];
        else
            % No neighbor close enough
            risAssignment{s} = u_near_idx;
        end
    end
end
