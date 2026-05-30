function [SE_P_MMSE, SE_MR_dist] = SE_uplink(Hhat,H,D,B,C,tau_c,tau_p,nbrOfRealizations,N,K,L,p,R,pilotIndex)

%Store the N x N identity matrix
eyeN = eye(N);

%Calcular el factor prelog considerando únicamente la transmisión de datos en el enlace ascendente
prelogFactor = (1 - tau_p / tau_c);

%Preparar para almacenar los resultados
SE_P_MMSE = zeros(K,1);
SE_MR_dist = zeros(K,1);

%Preparar para almacenar los términos que aparecen en SE_MR_dist
gki_MR = zeros(K,L,K);
gki2_MR = zeros(K,L,K);
Fk_MR = zeros(L,K);

%% Calcular expectativas de forma cerrada de MR para caso distribuido
for l = 1:L
    servedUEs = find(D(l,:) == 1);
    for ind = 1:length(servedUEs)
        k = servedUEs(ind);
        Fk_MR(l,k) = trace(B(:,:,l,k));
        for i = 1:K
            gki2_MR(i,l,k) = real(trace(B(:,:,l,k)*R(:,:,l,i))); 
            if pilotIndex(k) == pilotIndex(i)
                gki_MR(i,l,k) = real(trace((B(:,:,l,k)/R(:,:,l,k))*R(:,:,l,i)));
                gki2_MR(i,l,k) = gki2_MR(i,l,k) + (gki_MR(i,l,k))^2;
            end
        end
    end
end

%% Realizaciones de bucle sobre canal
for n = 1:nbrOfRealizations
    
    for k = 1:K
        % Encuentra lo APs de servicio para UE k
        servingAPs = find(D(:,k)==1);
        La = length(servingAPs);
        servedUEs = sum(D(servingAPs,:),1)>=1;

        Hallj_active = zeros(N*La,K);     % Canales reales desde APs activos
        Hhatallj_active = zeros(N*La,K);  % Estimaciones de canal desde APs activos
        C_tot_blk = zeros(N*La,N*La);     % Covarianza total del error de estimación
        C_tot_blk_partial = zeros(N*La,N*La);  % Covarianza parcial (solo UEs atendidos)

        for l = 1:La
            Hallj_active((l-1)*N+1:l*N,:) = reshape(H((servingAPs(l)-1)*N+1:servingAPs(l)*N,n,:), [N K]);
            Hhatallj_active((l-1)*N+1:l*N,:) = reshape(Hhat((servingAPs(l)-1)*N+1:servingAPs(l)*N,n,:), [N K]);
            C_tot_blk((l-1)*N+1:l*N,(l-1)*N+1:l*N) = sum(C(:,:,servingAPs(l),:),4);
            C_tot_blk_partial((l-1)*N+1:l*N,(l-1)*N+1:l*N) = sum(C(:,:,servingAPs(l),servedUEs),4);
        end

        % SE_P_MMSE
        v = p * ((p * (Hhatallj_active(:,servedUEs)*Hhatallj_active(:,servedUEs)') + ...
            p*C_tot_blk_partial + eye(La*N)) \ Hhatallj_active(:,k));
        numerator = p * abs(v' * Hhatallj_active(:,k))^2;
        denominator = p * norm(v' * Hhatallj_active)^2 + v' * (p*C_tot_blk + eye(La*N)) * v - numerator;
        
        SE_P_MMSE(k) = SE_P_MMSE(k) + prelogFactor * real(log2(1 + numerator/denominator)) / nbrOfRealizations;
    end
end

% SE_MR_dist
for k = 1:K
    % Encuentra lo APs de servicio para UE k
    servingAPs = find(D(:,k)==1); 
    La = length(servingAPs);
    % Calcular los pesos correspondientes para el caso sin LSFD
    a_dist = ones(La,1);
    % Valor esperado de g_{kk}, escalado por \sqrt{p} para combinación de MR local
    num_vector = vec(sqrt(p)*gki_MR(k,servingAPs,k));
    % Calcular la matriz del denominador para calcular SE usando los momentos
    %de primer y segundo orden de las entradas en los vectores g_{ki}
    temporMatrrr =  gki_MR(:,servingAPs,k).'*conj(gki_MR(:,servingAPs,k));
    denom_matrix = p*(diag(sum(gki2_MR(:,servingAPs,k),1))...
        +temporMatrrr-diag(diag(temporMatrrr)))...
        -num_vector*num_vector'...
        +diag(Fk_MR(servingAPs,k));

    SE_MR_dist(k) = prelogFactor*real(log2(1+abs(a_dist'*num_vector)^2/(a_dist'*denom_matrix*a_dist)));
end