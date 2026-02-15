function RISassignment_array = getRISAssignments_closest_two(file_indices)
    % GETRISASSIGNMENTS_CLOSEST_TWO Loads distance matrices and returns 
    % the indices of the 2 closest users for each RIS in a cell array.
    % Input: file_indices (e.g., 1:7)
    % Output: 25xN cell array
    
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
                
                % Iterate through each RIS (row)
                for ris_idx = 1:num_ris
                    % Sort distances for the current RIS
                    [~, sorted_indices] = sort(dist_matrix(ris_idx, :), 'ascend');
                    
                    % Take the first 2 indices and store as a row vector in a cell
                    RISassignment_array{ris_idx, i} = sorted_indices(1:2);
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