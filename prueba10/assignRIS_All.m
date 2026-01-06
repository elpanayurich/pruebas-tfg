function risAssignment = assignRIS_All(probLoS_AP_UE, probLoS_RIS_UE)
    [S, K] = size(probLoS_RIS_UE);
    
    risAssignment = cell(S, 1);
    
    allUsers = 1:K;
    
    for s = 1:S
        risAssignment{s} = allUsers;
    end

end
