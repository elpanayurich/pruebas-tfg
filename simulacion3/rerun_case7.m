% rerun_case7.m
clear;
close all;

load('results_comparison.mat');
c_idx = 7;
case_name = cases{c_idx};
fprintf('Re-running Case %d: %s...\n', c_idx, case_name);

% Setup parameters
L = 16;
N_AP = 1;
N_RIS = 64;
tau_c = 10000;
p = 100;
fc = 3.5;
LoS = 2;
ASD_varphi = deg2rad(15);
S = (sqrt(L) + 1)^2; 

tau_p = K * 1 * (1 + N_RIS) + K;

SE_PMMSE_case = zeros(K, nbrOfSetups);
setup_seed = 9;

for n = 1:nbrOfSetups
    fprintf('  Setup %d/%d...\n', n, nbrOfSetups);
    
    seed = randi(1000);
    setup_seed = setup_seed + 1;
    [R_AP_UE, R_AP_RIS1, R_AP_RIS2, R_RIS_UE, pilotIndex, D, HMean_AP_UE, HMean_AP_RIS, HMean_RIS_UE, probLoS_AP_UE, probLoS_RIS_UE, dist_RIS_UE, UEpositions] = setup(L, K, N_AP, N_RIS, tau_p, seed, ASD_varphi, LoS, fc, S, setup_seed);
    
    risAssignment = cell(S, 1);
    temp_dist = dist_RIS_UE;
    for i = 1:K
        [~, min_idx] = min(temp_dist(:));
        [best_ris, best_ue] = ind2sub(size(temp_dist), min_idx);
        risAssignment{best_ris} = best_ue;
        temp_dist(best_ris, :) = inf;
        temp_dist(:, best_ue) = inf;
    end
    
    [Hhat, H_eq, R_eq, B, C] = channelEstimates(R_AP_UE, R_AP_RIS1, R_AP_RIS2, R_RIS_UE, 100, L, K, S, N_AP, N_RIS, tau_p, pilotIndex, p, HMean_AP_UE, HMean_AP_RIS, HMean_RIS_UE, risAssignment);
    [SE_P_MMSE, ~] = SE_uplink(Hhat, H_eq, D, B, C, tau_c, tau_p, 100, N_AP, K, L, p, R_eq, pilotIndex);
    
    SE_PMMSE_case(:, n) = SE_P_MMSE;
end

SE_results{c_idx} = SE_PMMSE_case;
save('results_comparison.mat', 'SE_results', 'cases', 'K', 'nbrOfSetups');

fig_ind = figure('Visible', 'off'); hold on; box on;
set(gca,'fontsize',16);
plot(sort(SE_PMMSE_case(:)), linspace(0,1,K*nbrOfSetups), 'k-', 'LineWidth', 2);
xlabel('Spectral efficiency [bit/s/Hz]', 'Interpreter', 'Latex');
ylabel('CDF', 'Interpreter', 'Latex');
xlim([0 25]);
grid on;
fig_filename = fullfile('figures_clean', [case_name '.fig']);
savefig(fig_ind, fig_filename);
close(fig_ind);

fprintf('Case 7 re-run successfully.\n');
