function RISassignment_array = getRISAssignments_threshold(file_indices, threshold)
    % GETRISASSIGNMENTS_THRESHOLD Loads distance matrices and returns 
    % the closest user, and the second closest ONLY if within 150 units.
    % Input: file_indices (e.g., 1:7)
    % Output: 25xN cell array (each cell contains 1 or 2 indices)
    
    num_files = length(file_indices);
    num_ris = 25;
    
    % Pre-allocate the cell array
    RISassignment_array = cell(num_ris, num_files);
    
    for i = 1:num_files
        X = file_indices(i);
        filename = sprintf('positions/positions%d.mat', X);
        
        if exist(filename, 'file')
            data = load(filename);
            
            if isfield(data, 'dist_RIS_UE')
                dist_matrix = data.dist_RIS_UE;
                
                for ris_idx = 1:num_ris
                    % Get distances and indices for current RIS
                    [sorted_dist, sorted_indices] = sort(dist_matrix(ris_idx, :), 'ascend');
                    
                    % Logic: Always take the 1st closest. 
                    % Take the 2nd only if its distance is <= 150.
                    if sorted_dist(2) <= threshold
                        RISassignment_array{ris_idx, i} = sorted_indices(1:2);
                    else
                        RISassignment_array{ris_idx, i} = sorted_indices(1);
                    end
                end
                
                fprintf('Processed: positions%d.mat\n', X);
            else
                warning('Variable "dist_RIS_UE" not found in %s', filename);
            end
        else
            warning('File %s not found. Skipping...', filename);
        end
    end
end