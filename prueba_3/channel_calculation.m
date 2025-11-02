function [H_AP_UE] = channel_calculation(K, L, N, nbrOfSetups, fc, APlocations, UElocations)

    %Heights and relative distances
    c = 3e8; 
    h_AP = 10;
    h_UE = 1.5;
    h_E = 1;
    h_AP_eff = h_AP - h_E;
    h_UE_eff = h_UE - h_E;
    d_BP_eff = 4*h_AP_eff*h_UE_eff*((fc*1e9)/c);

    APlocationsVec = APlocations(:);
    dist_AP_UE = zeros(L, K, nbrOfSetups);
    for s = 1:nbrOfSetups
        for k = 1:K
            for l = 1:L
                d_1 = abs(APlocationsVec(l) - UElocations(s, k));
                d_2 = h_AP - h_UE;
                dist_AP_UE(l, k, s) = sqrt(d_1^2 + d_2^2);
            end
        end
    end

    %Channel calculation
    H_AP_UE = zeros(N*L, K, nbrOfSetups);
    maxdistances = 500;
    lambda = c/fc;
    sigma_sf = 4;

    betaLoS_AP_UE = zeros(L,1);
    PathNLoss_aux_AP_UE = zeros(L,1);
    betaNLoS_AP_UE = zeros(L,1);
    probLoS_AP_UE = zeros(L,K);

    shadowCorrMatrix_AP_UE = sigma_sf^2*ones(K,K);
    shadowAPrealizations_AP_UE = zeros(K,L);
    
    for s = 1:nbrOfSetups
        for k = 1:K
            for l = 1:L
                d = dist_AP_UE(l,k,s);

                %Loss in dB for LoS
                if d >= 10 && d <= d_BP_eff
                    betaLoS_AP_UE(l) = 32.4 + 21 * log10(d) + 20 * log10(fc);
                elseif d > d_BP_eff && d <= 5000
                    betaLoS_AP_UE(l) = 32.4 + 40 * log10(d) + 20 * log10(fc) - 9.5 * log10(d_BP_eff^2 + (h_AP - h_UE)^2);
                end

                %Loss in dB for NLoS
                PathNLoss_aux_AP_UE(l) = 35.3 * log10(d) + 22.4 + 21.3 * log10(fc) - 0.3 * (h_UE - 1.5);
                betaNLoS_AP_UE(l) = max(betaLoS_AP_UE(l),PathNLoss_aux_AP_UE(l));
            end
            
            %Always random the prob of LoS or NLoS (if further than 500malways NLoS)
            probLoS_AP_UE(:,k) = (rand<((maxdistances-dist_AP_UE(:,k, s))./maxdistances));

            %Shadowing generation (UEs correlated)
            if k == 1
                %First UE
                meanvalues = 0;
                stdvalue = sigma_sf;
                newcolumn = [];
            else
                
            end
        end
    end
       
end