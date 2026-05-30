function [dist_AP_UE, dist_RIS_UE, dist_AP_RIS, whichpos] = calculate_distances(APpositions, RISpositions, UEpositions, APpositionsWrapped,  K, L, S, h_BS, h_UT, h_RIS)
    dist_AP_UE = zeros(L,K);        % Distancias AP-UE
    dist_RIS_UE = zeros(S,K);       % Distancias RIS-UE
    dist_AP_RIS = zeros(L,S);       % Distancias AP-RIS
    
    distanceVertical_AP_UE = h_BS - h_UT;
    distanceVertical_RIS_UE = h_RIS - h_UT;
    for k = 1:K
        UEposition = UEpositions(k);
        [distanceAPstoUE, whichpos] = min(abs(APpositionsWrapped - repmat(UEposition, size(APpositionsWrapped))), [], 2);
        dist_AP_UE(:,k) = sqrt(distanceVertical_AP_UE^2 + distanceAPstoUE.^2);
        dist_RIS_UE(:,k) = sqrt(distanceVertical_RIS_UE^2 + abs(UEposition - RISpositions).^2);
    end
    
    for s = 1:S
        dist_AP_RIS(:,s) = abs(APpositions - RISpositions(s));
    end
end