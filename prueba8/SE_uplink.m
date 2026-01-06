function [SE_P_MMSE, SE_MR_dist] = SE_uplink_Vectorized(Hhat,H,D,B,C,tau_c,tau_p,nbrOfRealizations,N,K,L,p,R,pilotIndex)

% Determine backend
if isa(Hhat, 'gpuArray')
    arrayFactory = @(varargin) gpuArray.zeros(varargin{:});
    eyeFactory   = @(n) gpuArray.eye(n);
else
    arrayFactory = @(varargin) zeros(varargin{:});
    eyeFactory   = @(n) eye(n);
end

%Store the N x N identity matrix
eyeN = eyeFactory(N);

%Calcular el factor prelog
prelogFactor = (1 - tau_p / tau_c);

%Preparar para almacenar los resultados
SE_P_MMSE = arrayFactory(K,1);
SE_MR_dist = arrayFactory(K,1);

%Preparar para almacenar los términos que aparecen en SE_MR_dist
gki_MR = arrayFactory(K,L,K);
gki2_MR = arrayFactory(K,L,K);
Fk_MR = arrayFactory(L,K);

%% Calcular expectativas de forma cerrada de MR (Identical to original, usually fast)
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

%% Realizaciones de bucle sobre canal (Vectorized)

% SE_P_MMSE calculation
% Loop over K users (K is small ~10). 
% We vectorize the 'nbrOfRealizations' dimension.

SE_P_MMSE_accum = arrayFactory(K, nbrOfRealizations);

for k = 1:K
    % Find serving APs for UE k
    servingAPs = find(D(:,k)==1);
    La = length(servingAPs);
    
    % Which UEs are served by these APs?
    % D(servingAPs,:) is (La x K). 
    % servedUEs_indices is a logical mask of UEs served by *at least one* of the serving APs of k.
    servedUEs_mask = sum(D(servingAPs,:),1)>=1; % (1 x K) logical
    
    num_served = sum(servedUEs_mask);
    
    % Construct active matrices (Stacked over APs)
    % Hhat: (L*N, R, K)
    % C: (N, N, L, K)
    
    % We need to assemble block matrices.
    % Hhatallj_active: (N*La, R, NumServedUEs)
    % But wait, original code:
    % Hhatallj_active = zeros(N*La,K);  <-- This was (N*La, K) per realization.
    % Now we want: (N*La, NumServedUEs, R) for pagemtimes?
    % Or (N*La, K, R)?
    
    % The equation:
    % v = p * ((p * (Hhat_active * Hhat_active') + p*C_tot + eye) \ Hhat_k)
    % Dimensions in vectorized form:
    % Hhat_active: (N*La, NumServedUEs, R)
    % Hhat_active': (NumServedUEs, N*La, R)
    % Product: (N*La, N*La, R)
    
    % Let's build Hhatallj_active for all Realizations
    Hhatallj_active = arrayFactory(N*La, num_served, nbrOfRealizations);
    C_tot_blk_partial = arrayFactory(N*La, N*La); % Constant over realizations (Mean)
    C_tot_blk = arrayFactory(N*La, N*La);
    
    % Build the blocks
    current_row = 0;
    for idx_l = 1:La
        l = servingAPs(idx_l);
        rows = (current_row+1):(current_row+N);
        current_row = current_row + N;
        
        idx_AP = (l-1)*N+1:l*N;
        
        % Hhat for this AP, all realizations, all served UEs
        % Hhat(idx_AP, :, servedUEs_mask) -> (N, R, NumServed)
        % Permute to (N, NumServed, R)
        block = Hhat(idx_AP, :, servedUEs_mask);
        Hhatallj_active(rows, :, :) = permute(block, [1, 3, 2]);
        
        % C matrices (sum over 4th dim = K)
        % C(:,:,l,:) -> (N, N, 1, K)
        C_tot_blk(rows, rows) = sum(C(:,:,l,:),4);
        C_tot_blk_partial(rows, rows) = sum(C(:,:,l,servedUEs_mask),4);
    end
    
    % Compute term inside inverse
    % Hhat * Hhat'
    % (N*La, NumServed, R) * (NumServed, N*La, R) -> (N*La, N*La, R)
    HH_H = pagemtimes(Hhatallj_active, pagectranspose(Hhatallj_active));
    
    % C terms are constant over R, broadcast them
    % eye is constant
    Identity = eyeFactory(La*N);
    
    % Matrix to invert: A_inv
    A_to_inv = p * HH_H + p * C_tot_blk_partial + Identity; % (N*La, N*La, R)
    
    % RHS: Hhatallj_active(:, k) -> Hhat for user k
    % Wait, Hhatallj_active contains only servedUEs.
    % User k is one of them. Find index of k in servedUEs_mask.
    served_indices = find(servedUEs_mask);
    k_idx_in_served = find(served_indices == k);
    
    Hhat_k = Hhatallj_active(:, k_idx_in_served, :); % (N*La, 1, R)
    
    % v = p * (A \ Hhat_k)
    v = p * pagemldivide(A_to_inv, Hhat_k); % (N*La, 1, R)
    
    % Numerator: p * |v' * Hhat_k|^2
    % v': (1, N*La, R)
    % v' * Hhat_k -> (1, 1, R)
    inner = pagemtimes(pagectranspose(v), Hhat_k);
    numerator = p * abs(inner).^2;
    
    % Denominator
    % Term 1: p * norm(v' * Hhat)^2
    % v' * Hhatallj_active -> (1, NumServed, R)
    % norm^2 is sum(abs(...).^2)
    prod_v_H = pagemtimes(pagectranspose(v), Hhatallj_active);
    term1 = p * sum(abs(prod_v_H).^2, 2); % (1, 1, R)
    
    % Term 2: v' * (p*C_tot + eye) * v
    % Middle matrix M = p*C_tot_blk + Identity
    M = p * C_tot_blk + Identity;
    % v' * M * v
    % (1, N*La, R) * (N*La, N*La) * (N*La, 1, R)
    % M broadcasts
    M_v = pagemtimes(M, v);
    term2 = pagemtimes(pagectranspose(v), M_v);
    
    denominator = term1 + term2 - numerator;
    
    % Calculate SE for each realization
    val = real(log2(1 + numerator ./ denominator)); % (1, 1, R)
    
    SE_P_MMSE_accum(k, :) = val(:);
end

% Average over realizations
SE_P_MMSE = prelogFactor * mean(SE_P_MMSE_accum, 2);


% SE_MR_dist calculation (Identical to original, it's already fast/vectorized over K)
for k = 1:K
    servingAPs = find(D(:,k)==1); 
    La = length(servingAPs);
    a_dist = ones(La,1);
    num_vector = vec(sqrt(p)*gki_MR(k,servingAPs,k));
    temporMatrrr =  gki_MR(:,servingAPs,k).'*conj(gki_MR(:,servingAPs,k));
    denom_matrix = p*(diag(sum(gki2_MR(:,servingAPs,k),1))...
        +temporMatrrr-diag(diag(temporMatrrr)))...
        -num_vector*num_vector'...
        +diag(Fk_MR(servingAPs,k));

    SE_MR_dist(k) = prelogFactor*real(log2(1+abs(a_dist'*num_vector)^2/(a_dist'*denom_matrix*a_dist)));
end

end
