function [Hhat,H_eq,R_eq,B,C] = channelEstimates(R_AP_UE,R_AP_RIS1,R_AP_RIS2,R_RIS_UE,nbrOfRealizations,L,K,S,N_AP,N_RIS,tau_p,pilotIndex,p,HMeanWithoutPhase_AP_UE,HMeanWithoutPhase_AP_RIS,HMeanWithoutPhase_RIS_UE,risAssignment)
%% Generar realizaciones de canal

%----- AP-UE -----
% Generar canal Rician para AP-UE
M_AP_UE = L*N_AP;
H_AP_UE = zeros(M_AP_UE, nbrOfRealizations, K); % Canal resultante
W_AP_UE = (randn(M_AP_UE, nbrOfRealizations, K) + 1i * randn(M_AP_UE, nbrOfRealizations, K));   % Ruido gaussiano complejo

% Media del canal AP-UE
HMean_AP_UE=zeros(M_AP_UE,nbrOfRealizations,K); 
HMeanx_AP_UE=reshape(repmat(HMeanWithoutPhase_AP_UE,nbrOfRealizations,1),M_AP_UE,nbrOfRealizations,K);

% Fase aleatoria para componente LoS AP-UE
angles_AP_UE= -pi + 2*pi*rand(M_AP_UE,nbrOfRealizations,K);
phaseMatrix_AP_UE=exp(1i*angles_AP_UE);

% Canal Rician con correlación espacial AP-UE
for l = 1:L
    for k = 1:K
        
        HMean_AP_UE(:,:,k)= phaseMatrix_AP_UE(:,:,k).*HMeanx_AP_UE(:,:,k);  % Aplicar fase aleatoria
        Rsqrt = sqrtm(R_AP_UE(:,:,l,k));
        H_AP_UE((l-1)*N_AP+1:l*N_AP,:,k) = sqrt(0.5)*Rsqrt*W_AP_UE((l-1)*N_AP+1:l*N_AP,:,k) + HMean_AP_UE((l-1)*N_AP+1:l*N_AP,:,k);
       
    end
end

% ----- RIS-UE -----
% Generar canal Rician para RIS-UE
M_RIS_UE = S*N_RIS;
H_RIS_UE = zeros(M_RIS_UE, nbrOfRealizations, K); % Canal resultante
W_RIS_UE = (randn(M_RIS_UE, nbrOfRealizations, K) + 1i * randn(M_RIS_UE, nbrOfRealizations, K));   % Ruido gaussiano complejo

% Media del canal RIS-UE
HMean_RIS_UE=zeros(M_RIS_UE,nbrOfRealizations,K); 
HMeanx_RIS_UE=reshape(repmat(HMeanWithoutPhase_RIS_UE,nbrOfRealizations,1),M_RIS_UE,nbrOfRealizations,K);
 
% Fase aleatoria para componente LoS RIS-UE
angles_RIS_UE= -pi + 2*pi*rand(M_RIS_UE,nbrOfRealizations,K);
phaseMatrix_RIS_UE=exp(1i*angles_RIS_UE);

% Canal Rician con correlación espacial RIS-UE
for s = 1:S
    for k = 1:K
        
        HMean_RIS_UE(:,:,k)= phaseMatrix_RIS_UE(:,:,k).*HMeanx_RIS_UE(:,:,k);  % Aplicar fase aleatoria
        Rsqrt = sqrtm(R_RIS_UE(:,:,s,k));
        H_RIS_UE((s-1)*N_RIS+1:s*N_RIS,:,k) = sqrt(0.5)*Rsqrt*W_RIS_UE((s-1)*N_RIS+1:s*N_RIS,:,k) + HMean_RIS_UE((s-1)*N_RIS+1:s*N_RIS,:,k);
       
    end
end

% ----- AP-RIS -----
% Generar canal Rician para AP-RIS
H_AP_RIS = zeros(L*N_AP, S*N_RIS, nbrOfRealizations);
W_AP_RIS = randn(L*N_AP, S*N_RIS, nbrOfRealizations) + 1i*randn(L*N_AP, S*N_RIS, nbrOfRealizations);

HMean_AP_RIS = zeros(L*N_AP, S*N_RIS, nbrOfRealizations);
HMeanx_AP_RIS = reshape(repmat(HMeanWithoutPhase_AP_RIS, 1, nbrOfRealizations), L*N_AP, S*N_RIS, nbrOfRealizations);

angles_AP_RIS = -pi + 2*pi*rand(L*N_AP, S*N_RIS, nbrOfRealizations);
phaseMatrix_AP_RIS = exp(1i*angles_AP_RIS);

for l = 1:L
    for s = 1:S
        % Actualiza la media con fase aleatoria para el bloque (l,s)
        HMean_AP_RIS(:,(s-1)*N_RIS+1:s*N_RIS,:) = phaseMatrix_AP_RIS(:, (s-1)*N_RIS+1:s*N_RIS, :) .* HMeanx_AP_RIS(:, (s-1)*N_RIS+1:s*N_RIS, :);

        Rsqrt1 = sqrtm(R_AP_RIS1(:,:,l,s));
        Rsqrt2 = sqrtm(R_AP_RIS2(:,:,l,s));

        for t = 1:nbrOfRealizations
            % Multiplicación matricial sin squeeze, accediendo directo
            H_AP_RIS((l-1)*N_AP+1:l*N_AP, (s-1)*N_RIS+1:s*N_RIS, t) = sqrt(0.5)*Rsqrt1*W_AP_RIS((l-1)*N_AP+1:l*N_AP,(s-1)*N_RIS+1:s*N_RIS,t)*Rsqrt2 + HMean_AP_RIS((l-1)*N_AP+1:l*N_AP,(s-1)*N_RIS+1:s*N_RIS,t);
        end
    end
end


%% Calculo de thetaMatrix y H_eq

% Inicializamos 
thetaMatrix = zeros(N_RIS,S);
H_eq_aux = zeros(M_AP_UE, K, nbrOfRealizations); 
R_eq = zeros(N_AP, N_AP, L, K);

for t = 1:nbrOfRealizations  % Por cada realización
    for s = 1:S             % Por cada RIS
        thetaMatrix(:,s) = exp(1i*2*pi*rand(N_RIS,1)); % dim: (N_RISxS,nbrOfRealizations)

        % Canal directo AP-UE, para realización t
        h_s = squeeze(H_AP_UE(:, t, risAssignment{s}));  % dim: (M_AP_UE x 1)

        % Canal RIS elemento - UE, para realización t
        h_t = squeeze(H_RIS_UE((s - 1)*N_RIS + 1:s*N_RIS, t, risAssignment{s}));  

        % Canal AP-RIS elemento idx_RIS, para realización t
        h_r = H_AP_RIS(:, (s - 1)*N_RIS + 1:s*N_RIS, t);  % dim: (L*N_AP x 1)

        for n = 1:N_RIS      % Por cada elemento n de la RIS s

            Hn = h_s + h_r*diag(thetaMatrix(:,s))*h_t - thetaMatrix(n,s)*h_r(:,n)*h_t(n,:);
            bn = p*Hn*h_t(n,:)';
            An = eye(N_AP*L) + p*(Hn*Hn') + p*h_r(:,n)*h_t(n,:)*(h_r(:,n)*h_t(n,:))';

            thetaMatrix(n,s) = exp(-1i*angle(bn'*(An\h_r(:,n))));              
        end        
    end

    h_reflected(:,:,t) =  H_AP_RIS(:,:,t) * diag(thetaMatrix(:)) * squeeze(H_RIS_UE(:, t, :));  % dim: (1x L*N_AP)
    H_eq_aux(:,:,t) = squeeze(H_AP_UE(:,t,:)) + h_reflected(:,:,t);
    H_eq = permute(H_eq_aux,[1,3,2]);

    for k = 1:K
        H_eq_aux1 = H_eq(:,t,k);
        H_eq_aux2 = reshape(H_eq_aux1,N_AP,L);
        for l = 1:L
            R_eq(:,:,l,k) = R_eq(:,:,l,k) + (H_eq_aux2(:,l)- HMean_AP_UE(l,t,k)).*(H_eq_aux2(:,l)-HMean_AP_UE(l,t,k))';
        end
    end
end

R_eq = R_eq / nbrOfRealizations;

     
%% Estimación del canal

% Matriz identidad de tamaño N_APxN_AP
eyeN_AP = eye(N_AP);

% Ruido normalizado para la estimación de piloto AP-UE
Np = sqrt(0.5)*(randn(N_AP,nbrOfRealizations,L,tau_p) + 1i*randn(N_AP,nbrOfRealizations,L,tau_p));

% Preparar para almacenar los resultados AP-UE
Hhat = zeros(L*N_AP,nbrOfRealizations,K);

% Reservar matriz de correlación de estimación si se requiere
if nargout>2
    B = zeros(size(R_eq));
end

% Reservar matriz de error de estimación si se requiere
if nargout>3
    C = zeros(size(R_eq));
end

% Para cada AP
for l = 1:L
    
    % Para cada piloto
    for t = 1:tau_p
        
        % Señal recibida procesada
        yp = sqrt(p)*tau_p*sum(H_eq((l-1)*N_AP+1:l*N_AP,:,t==pilotIndex),3) + sqrt(tau_p)*Np(:,:,l,t);
        yMean = zeros(N_AP, nbrOfRealizations);  % Inicializar la media esperada de y
        
        % Matriz a invertir en el estimador MMSE
        PsiInv = (p*tau_p*sum(R_eq(:,:,l,t==pilotIndex),4) + eyeN_AP);
        
        % Para cada usuario que usa el piloto t
        for k = find(t==pilotIndex)'
            % Calcular estimación del canal
            RPsi = R_eq(:,:,l,k) / PsiInv;
            yMean = yMean + sqrt(p)*tau_p*HMean_AP_UE((l-1)*N_AP+1:l*N_AP,:,k);
            Hhat((l-1)*N_AP+1:l*N_AP,:,k) = sqrt(p)*RPsi*(yp - yMean) + HMean_AP_UE((l-1)*N_AP+1:l*N_AP,:,k);
            
            % Correlación de estimación
            if nargout>2
                B(:,:,l,k) = p*tau_p*RPsi*R_eq(:,:,l,k);
            end
            
            % Correlación del error de estimación
            if nargout>3
                C(:,:,l,k) = R_eq(:,:,l,k) - B(:,:,l,k);
            end
            
        end
        
    end
    
end

