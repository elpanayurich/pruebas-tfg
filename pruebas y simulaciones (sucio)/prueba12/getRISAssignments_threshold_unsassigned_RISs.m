function [RISassignment_array, assigned_counts, unassigned_counts] = getRISAssignments_threshold_unsassigned_RISs(file_indices, threshold)
    % GETRISASSIGNMENTS_THRESHOLD_UNASSIGNED_RISS Loads distance matrices and returns 
    % the closest user, and the second closest ONLY if within 150 units.
    % If the closest user is > 250m, no user is assigned.
    % Input: file_indices (e.g., 1:7)
    % Output: 
    %   RISassignment_array: 25xN cell array (each cell contains 0, 1 or 2 indices)
    %   assigned_counts: 1xN array with the number of assigned RISs per file
    %   unassigned_counts: 1xN array with the number of unassigned RISs per file
    
    num_files = length(file_indices);
    num_ris = 25;
    
    % Pre-allocate
    RISassignment_array = cell(num_ris, num_files);
    assigned_counts = zeros(1, num_files);
    unassigned_counts = zeros(1, num_files);
    
    for i = 1:num_files
        X = file_indices(i);
        filename = sprintf('positions/positions%d.mat', X);
        
        if exist(filename, 'file')
            data = load(filename);
            
            if isfield(data, 'dist_RIS_UE')
                dist_matrix = data.dist_RIS_UE;
                
                curr_assigned = 0;
                curr_unassigned = 0;
                
                for ris_idx = 1:num_ris
                    [sorted_dist, sorted_indices] = sort(dist_matrix(ris_idx, :), 'ascend');
                    
                    if sorted_dist(1) > 250
                         RISassignment_array{ris_idx, i} = [];
                         curr_unassigned = curr_unassigned + 1;
                    else
                        curr_assigned = curr_assigned + 1;
                        if sorted_dist(2) <= threshold
                            RISassignment_array{ris_idx, i} = sorted_indices(1:2);
                        else
                            RISassignment_array{ris_idx, i} = sorted_indices(1);
                        end
                    end
                end
                
                assigned_counts(i) = curr_assigned;
                unassigned_counts(i) = curr_unassigned;
                
                fprintf('Processed: positions%d.mat (Assigned: %d, Unassigned: %d)\n', X, curr_assigned, curr_unassigned);
            else
                warning('Variable "dist_RIS_UE" not found in %s', filename);
            end
        else
            warning('File %s not found. Skipping...', filename);
        end
    end
end