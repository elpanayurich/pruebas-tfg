function RISassignment_array = getRISAssignments_closest(file_indices)
    % GETRISASSIGNMENTS Loads distance matrices and returns the closest user index.
    % Input: file_indices (e.g., 1:7)
    % Output: 25xN matrix where N is the number of files
    
    % Pre-allocate the array (assuming 25 RISs)
    num_files = length(file_indices);
    RISassignment_array = zeros(25, num_files);
    
    for i = 1:num_files
        X = file_indices(i);
        filename = sprintf('positions/positions%d.mat', X);
        
        if exist(filename, 'file')
            % Load data into a structure to keep the workspace clean
            data = load(filename);
            
            % Access the specific variable from the file
            if isfield(data, 'dist_RIS_UE')
                dist_matrix = data.dist_RIS_UE;
                
                % Find index of minimum distance for each row (RIS)
                [~, assigned_users] = min(dist_matrix, [], 2);
                
                % Store result in the corresponding column
                RISassignment_array(:, i) = assigned_users;
                
                fprintf('Processed: positions%d.mat\n', X);
            else
                warning('Variable "dist_RIS_UE" not found in %s', filename);
            end
        else
            warning('File %s not found. Skipping...', filename);
        end
    end
end