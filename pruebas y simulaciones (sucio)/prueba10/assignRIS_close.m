function risAssignment = assignRIS_close(dist_RIS_UE)
    % assignRIS_close Assigns each RIS to the nearest user.
    % Input:
    %   dist_RIS_UE: Matrix (S x K) of distances between RIS and UEs.
    % Output:
    %   risAssignment: Cell array (1 x S) where each element is the user index.

    [S, ~] = size(dist_RIS_UE);
    risAssignment = cell(1, S);

    for s = 1:S
        [~, k] = min(dist_RIS_UE(s, :));
        risAssignment{s} = k;
    end
end
