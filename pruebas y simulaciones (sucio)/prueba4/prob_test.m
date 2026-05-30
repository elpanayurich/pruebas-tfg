L = 16;
K = 10;
S = 25;

probLoS_AP_UE = zeros(L,K);     % Probabilidad de LoS entre AP y UE
probLoS_AP_RIS = zeros(L,S);    % Probabilidad de LoS entre AP y RIS
probLoS_RIS_UE = zeros(S,K);    % Probabilidad de LoS entre RIS y UE

h_ut = 1.5;
h_ris = 10;
LoS = 2;


% AP-UE
if LoS==2
    for n=1:10
        if h_ut > 8
            C = ((h_ut - 8)/10)^1.5;
        else
            C = 0;
        end
        if dist_AP_UE > 18
            term1 = (18./dist_AP_UE(:,n)) + exp(-dist_AP_UE(:,n)./63) .* (1 - (18./dist_AP_UE(:,n)));
            term2 = 1 + C * (5/4) * ((dist_AP_UE(:,n)./100).^3) .* exp(-dist_AP_UE(:,n)./150);
            probLoS_AP_UE(:,n) = term1 .* term2;
        else
            probLoS_AP_UE(:,n) = 1;
        end
    end
end


% AP-RIS
if LoS==2
    for n=1:25
        if h_ris > 8
            C = ((h_ris - 8)/10)^1.5;
        else
            C = 0;
        end
        if dist_AP_RIS > 18
            term1 = (18./dist_AP_RIS(:,n)) + exp(-dist_AP_RIS(:,n)./63) .* (1 - (18./dist_AP_RIS(:,n)));
            term2 = 1 + C * (5/4) * ((dist_AP_RIS(:,n)./100).^3) .* exp(-dist_AP_RIS(:,n)./150);
            probLoS_AP_RIS(:,n) = term1 .* term2;
        else
            probLoS_AP_RIS(:,n) = 1;
        end
    end
end


% RIS-UE
if LoS==2
    for n=1:10
        if h_ut > 8
            C = ((h_ut - 8)/10)^1.5;
        else
            C = 0;
        end
        if dist_RIS_UE > 18
            term1 = (18./dist_RIS_UE(:,n)) + exp(-dist_RIS_UE(:,n)./63) .* (1 - (18./dist_RIS_UE(:,n)));
            term2 = 1 + C * (5/4) * ((dist_RIS_UE(:,n)./100).^3) .* exp(-dist_RIS_UE(:,n)./150);
            probLoS_RIS_UE(:,n) = term1 .* term2;
        else
            probLoS_RIS_UE(:,n) = 1;
        end
    end
end