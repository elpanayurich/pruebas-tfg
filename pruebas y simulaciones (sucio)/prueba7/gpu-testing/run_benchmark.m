% run_benchmark.m

% Load data
disp('Loading benchmark data...');
load('benchmark_data.mat');

disp(['Running benchmark with ' num2str(nbrOfRealizations) ' realizations...']);

%% 1. Original CPU Chain
disp('------------------------------------------------');
disp('Starting Original CPU Chain...');
tic;
[Hhat_CPU, H_eq_CPU, R_eq_CPU, B_CPU, C_CPU] = channelEstimates(R_AP_UE,R_AP_RIS1,R_AP_RIS2,R_RIS_UE,nbrOfRealizations,L,K,S,N_AP,N_RIS,tau_p,pilotIndex,p,HMean_AP_UE,HMean_AP_RIS, HMean_RIS_UE,risAssignment);
time_est_CPU = toc;
disp(['Est. CPU Time: ' num2str(time_est_CPU) ' s']);

tic;
[SE_CPU, ~] = SE_uplink(Hhat_CPU,H_eq_CPU,D,B_CPU,C_CPU,tau_c,tau_p,nbrOfRealizations,N_AP,K,L,p,R_eq_CPU,pilotIndex);
time_se_CPU = toc;
disp(['SE CPU Time:   ' num2str(time_se_CPU) ' s']);

total_CPU = time_est_CPU + time_se_CPU;

%% 2. Vectorized Chain
disp('------------------------------------------------');
disp('Starting Vectorized Chain...');
tic;
[Hhat_Vec, H_eq_Vec, R_eq_Vec, B_Vec, C_Vec] = channelEstimates_Vectorized(R_AP_UE,R_AP_RIS1,R_AP_RIS2,R_RIS_UE,nbrOfRealizations,L,K,S,N_AP,N_RIS,tau_p,pilotIndex,p,HMean_AP_UE,HMean_AP_RIS, HMean_RIS_UE,risAssignment);
time_est_Vec = toc;
disp(['Est. Vec Time: ' num2str(time_est_Vec) ' s']);

tic;
[SE_Vec, ~] = SE_uplink_Vectorized(Hhat_Vec,H_eq_Vec,D,B_Vec,C_Vec,tau_c,tau_p,nbrOfRealizations,N_AP,K,L,p,R_eq_Vec,pilotIndex);
time_se_Vec = toc;
disp(['SE Vec Time:   ' num2str(time_se_Vec) ' s']);

total_Vec = time_est_Vec + time_se_Vec;

%% Comparison
disp('------------------------------------------------');
disp(['Total CPU: ' num2str(total_CPU) ' s']);
disp(['Total Vec: ' num2str(total_Vec) ' s']);
disp(['Overall Speedup: ' num2str(total_CPU / total_Vec) 'x']);

% Check Accuracy
diff_SE = norm(SE_CPU - SE_Vec) / norm(SE_CPU);
disp(['SE Relative Difference: ' num2str(diff_SE)]);

if diff_SE < 1e-4
    disp('SE Validation PASSED.');
else
    disp('SE Validation WARNING: Difference too high.');
end
