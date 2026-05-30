function [Hhat,H_eq,R_eq,B,C] = channelEstimates_Vectorized(R_AP_UE,R_AP_RIS1,R_AP_RIS2,R_RIS_UE,nbrOfRealizations,L,K,S,N_AP,N_RIS,tau_p,pilotIndex,p,HMeanWithoutPhase_AP_UE,HMeanWithoutPhase_AP_RIS,HMeanWithoutPhase_RIS_UE,risAssignment)
%% Determine Backend (CPU or GPU)
% Check if inputs are gpuArray
if isa(R_AP_UE, 'gpuArray')
    arrayFactory = @(varargin) gpuArray.zeros(varargin{:});
    randnFactory = @(varargin) gpuArray.randn(varargin{:});
    eyeFactory   = @(n) gpuArray.eye(n);
else
    arrayFactory = @(varargin) zeros(varargin{:});
    randnFactory = @(varargin) randn(varargin{:});
    eyeFactory   = @(n) eye(n);
end

%% Generate Channel Realizations (Vectorized)

%----- AP-UE -----
M_AP_UE = L*N_AP;
% Generate random numbers
W_AP_UE = (randnFactory(M_AP_UE, nbrOfRealizations, K) + 1i * randnFactory(M_AP_UE, nbrOfRealizations, K));

HMeanx_AP_UE = reshape(repmat(HMeanWithoutPhase_AP_UE,nbrOfRealizations,1),M_AP_UE,nbrOfRealizations,K);
angles_AP_UE = -pi + 2*pi*rand(M_AP_UE,nbrOfRealizations,K);
if isa(R_AP_UE, 'gpuArray'), angles_AP_UE = gpuArray(angles_AP_UE); end
phaseMatrix_AP_UE = exp(1i*angles_AP_UE);

HMean_AP_UE = phaseMatrix_AP_UE .* HMeanx_AP_UE;
H_AP_UE = arrayFactory(M_AP_UE, nbrOfRealizations, K);

% Loop over L and K 
for l = 1:L
    for k = 1:K
        Rsqrt = safeSqrtm(R_AP_UE(:,:,l,k)); 
        idx = (l-1)*N_AP+1:l*N_AP;
        H_AP_UE(idx,:,k) = sqrt(0.5)*Rsqrt*W_AP_UE(idx,:,k) + HMean_AP_UE(idx,:,k);
    end
end

% ----- RIS-UE -----
M_RIS_UE = S*N_RIS;
W_RIS_UE = (randnFactory(M_RIS_UE, nbrOfRealizations, K) + 1i * randnFactory(M_RIS_UE, nbrOfRealizations, K));
HMeanx_RIS_UE = reshape(repmat(HMeanWithoutPhase_RIS_UE,nbrOfRealizations,1),M_RIS_UE,nbrOfRealizations,K);
angles_RIS_UE = -pi + 2*pi*rand(M_RIS_UE,nbrOfRealizations,K);
if isa(R_AP_UE, 'gpuArray'), angles_RIS_UE = gpuArray(angles_RIS_UE); end
phaseMatrix_RIS_UE = exp(1i*angles_RIS_UE);

HMean_RIS_UE = phaseMatrix_RIS_UE .* HMeanx_RIS_UE;
H_RIS_UE = arrayFactory(M_RIS_UE, nbrOfRealizations, K);

for s = 1:S
    for k = 1:K
        Rsqrt = safeSqrtm(R_RIS_UE(:,:,s,k));
        idx = (s-1)*N_RIS+1:s*N_RIS;
        H_RIS_UE(idx,:,k) = sqrt(0.5)*Rsqrt*W_RIS_UE(idx,:,k) + HMean_RIS_UE(idx,:,k);
    end
end

% ----- AP-RIS -----
H_AP_RIS = arrayFactory(L*N_AP, S*N_RIS, nbrOfRealizations);
W_AP_RIS = randnFactory(L*N_AP, S*N_RIS, nbrOfRealizations) + 1i*randnFactory(L*N_AP, S*N_RIS, nbrOfRealizations);

HMeanx_AP_RIS = reshape(repmat(HMeanWithoutPhase_AP_RIS, 1, nbrOfRealizations), L*N_AP, S*N_RIS, nbrOfRealizations);
angles_AP_RIS = -pi + 2*pi*rand(L*N_AP, S*N_RIS, nbrOfRealizations);
if isa(R_AP_UE, 'gpuArray'), angles_AP_RIS = gpuArray(angles_AP_RIS); end
phaseMatrix_AP_RIS = exp(1i*angles_AP_RIS);

HMean_AP_RIS = phaseMatrix_AP_RIS .* HMeanx_AP_RIS;

for l = 1:L
    for s = 1:S
        idx_AP = (l-1)*N_AP+1:l*N_AP;
        idx_RIS = (s-1)*N_RIS+1:s*N_RIS;
        
        Rsqrt1 = safeSqrtm(R_AP_RIS1(:,:,l,s));
        Rsqrt2 = safeSqrtm(R_AP_RIS2(:,:,l,s));
        
        W_slice = W_AP_RIS(idx_AP, idx_RIS, :);
        
        % pagemtimes works on both CPU (R2020b+) and GPU
        term1 = pagemtimes(Rsqrt1, W_slice);
        term2 = pagemtimes(term1, Rsqrt2);
        
        H_AP_RIS(idx_AP, idx_RIS, :) = sqrt(0.5)*term2 + HMean_AP_RIS(idx_AP, idx_RIS, :);
    end
end

%% Calculation of thetaMatrix and H_eq (Fully Vectorized over Realizations)

% Initialize thetaMatrix (N_RIS x S x nbrOfRealizations)
thetaMatrix = exp(1i*2*pi*rand(N_RIS, S, nbrOfRealizations));
if isa(R_AP_UE, 'gpuArray'), thetaMatrix = gpuArray(thetaMatrix); end

% Pre-allocate output
H_eq = arrayFactory(M_AP_UE, nbrOfRealizations, K);
R_eq = arrayFactory(N_AP, N_AP, L, K);

% Loop over surfaces (S)
for s = 1:S
    % Get assigned user for this RIS
    k_idx = risAssignment{s}; 
    
    % Extract channels
    h_s = reshape(H_AP_UE(:,:,k_idx), M_AP_UE, nbrOfRealizations); 
    idx_RIS = (s - 1)*N_RIS + 1:s*N_RIS;
    h_t = reshape(H_RIS_UE(idx_RIS, :, k_idx), N_RIS, nbrOfRealizations);
    h_r = H_AP_RIS(:, idx_RIS, :);
    
    % Loop over elements (n) - Coordinate Descent
    for n = 1:N_RIS
        
        theta_s = reshape(thetaMatrix(:, s, :), N_RIS, 1, nbrOfRealizations);
        
        combined_channel = theta_s .* reshape(h_t, N_RIS, 1, nbrOfRealizations); 
        
        H_reflected = pagemtimes(h_r, combined_channel);
        
        theta_n = reshape(thetaMatrix(n, s, :), 1, 1, nbrOfRealizations); 
        h_r_n = h_r(:, n, :); 
        h_t_n = reshape(h_t(n, :), 1, 1, nbrOfRealizations); 
        
        term_n = theta_n .* h_r_n .* h_t_n;
        
        Hn = reshape(h_s, M_AP_UE, 1, nbrOfRealizations) + H_reflected - term_n; 
        
        bn = p * Hn .* conj(h_t_n); 
        
        % Hn*Hn': (M x 1 x R) * (1 x M x R) -> (M x M x R)
        Hn_Hn_H = pagemtimes(Hn, pagectranspose(Hn));
        
        v = h_r_n .* h_t_n;
        v_v_H = pagemtimes(v, pagectranspose(v));
        
        An = eyeFactory(M_AP_UE) + p * Hn_Hn_H + p * v_v_H; 
        
        % Solve An \ h_r_n
        inv_prod = pagemldivide(An, h_r_n); 
        
        inner_prod = pagemtimes(pagectranspose(bn), inv_prod);
        
        new_theta = exp(-1i * angle(inner_prod));
        
        thetaMatrix(n, s, :) = reshape(new_theta, 1, 1, nbrOfRealizations);
    end
end

% Final H_eq calculation
for k = 1:K
    
    theta_flat = reshape(thetaMatrix, S*N_RIS, 1, nbrOfRealizations);
    h_ris_ue_k = reshape(H_RIS_UE(:,:,k), S*N_RIS, 1, nbrOfRealizations);
    
    combined = theta_flat .* h_ris_ue_k;
    h_ref_k = pagemtimes(H_AP_RIS, combined); 
    
    h_direct_k = reshape(H_AP_UE(:,:,k), M_AP_UE, 1, nbrOfRealizations);
    
    H_eq_k = h_direct_k + h_ref_k;
    H_eq(:,:,k) = reshape(H_eq_k, M_AP_UE, nbrOfRealizations);
    
    % Calculate R_eq (Covariance)
    mean_H = HMean_AP_UE(:,:,k);
    centered = H_eq(:,:,k) - mean_H;
    
    centered_reshaped = reshape(centered, N_AP, L, nbrOfRealizations);
    centered_perm = permute(centered_reshaped, [1, 3, 2]); % (N_AP, R, L)
    
    % Compute R * R' for each L
    % (N_AP x R x L) * (R x N_AP x L) -> (N_AP x N_AP x L)
    cov_matrices = pagemtimes(centered_perm, pagectranspose(centered_perm));
    
    R_eq(:,:,:,k) = cov_matrices / nbrOfRealizations;
end

%% Channel Estimation (Vectorized)

eyeN_AP = eyeFactory(N_AP);
Np = sqrt(0.5)*(randnFactory(N_AP,nbrOfRealizations,L,tau_p) + 1i*randnFactory(N_AP,nbrOfRealizations,L,tau_p));

Hhat = arrayFactory(L*N_AP,nbrOfRealizations,K);

if nargout>2
    B = arrayFactory(size(R_eq));
end
if nargout>3
    C = arrayFactory(size(R_eq));
end

for l = 1:L
    for t = 1:tau_p
        
        users_with_pilot = find(pilotIndex == t);
        
        sum_R = sum(R_eq(:,:,l,users_with_pilot), 4); 
        
        PsiInv = inv(p*tau_p*sum_R + eyeN_AP); 
        
        idx = (l-1)*N_AP+1:l*N_AP;
        H_eq_l = H_eq(idx, :, users_with_pilot); 
        
        sum_H = sum(H_eq_l, 3); 
        
        yp = sqrt(p)*tau_p*sum_H + sqrt(tau_p)*squeeze(Np(:,:,l,t)); 
        
        yMean = arrayFactory(N_AP, nbrOfRealizations);
        
        for k = users_with_pilot'
             % RPsi = R * PsiInv
             RPsi = R_eq(:,:,l,k) * PsiInv; 
             
             mean_val = sqrt(p)*tau_p*HMean_AP_UE(idx,:,k);
             yMean = yMean + mean_val;
             
             term = yp - yMean;
             
             Hhat(idx,:,k) = sqrt(p)*RPsi*term + HMean_AP_UE(idx,:,k);
             
             if nargout>2
                B(:,:,l,k) = p*tau_p*RPsi*R_eq(:,:,l,k);
             end
             if nargout>3
                C(:,:,l,k) = R_eq(:,:,l,k) - B(:,:,l,k);
             end
        end
    end
end

end

function S = safeSqrtm(A)
    if isa(A, 'gpuArray')
        S = gpuArray(sqrtm(gather(A)));
    else
        S = sqrtm(A);
    end
end
