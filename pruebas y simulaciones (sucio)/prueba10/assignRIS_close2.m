function risAssignment = assignRIS_close2(dist_RIS_UE)
    % assignRIS_close2 Assigns each RIS to the 2 nearest users.
    % Input:
    %   dist_RIS_UE: Matrix (S x K) of distances between RIS and UEs.
    % Output:
    %   risAssignment: Cell array (1 x S) where each element is a vector of 2 user indices.

    [S, ~] = size(dist_RIS_UE);
    risAssignment = cell(1, S);

    for s = 1:S
        % Sort the distances for the current RIS to find the nearest users
        [~, sortedIndices] = sort(dist_RIS_UE(s, :));
        
        % Assign the first 2 users (closest ones)
        risAssignment{s} = sortedIndices(1:2);
    end
end
