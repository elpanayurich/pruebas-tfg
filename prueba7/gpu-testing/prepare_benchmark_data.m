% prepare_benchmark_data.m
% This script runs the setup phase to generate inputs for channelEstimates
% and saves them to 'benchmark_data.mat'

clear;
L = 16;          
N_AP = 1;        
N_RIS = 100;     
K = 10;          
tau_c = 200;     
tau_p = 10;      
p = 100;         
fc = 3.5;        
LoS = 2;         
ASD_varphi = deg2rad(15);
S = 25; 
nbrOfRealizations = 100; 

disp('Generating setup data...');
seed = 1234; 
[R_AP_UE,R_AP_RIS1,R_AP_RIS2,R_RIS_UE,pilotIndex,D,HMean_AP_UE, HMean_AP_RIS, HMean_RIS_UE, probLoS_AP_UE, probLoS_RIS_UE] = setup(L,K,N_AP,N_RIS,tau_p,seed,ASD_varphi,LoS,fc,S);

risAssignment = assignRIS(probLoS_AP_UE, probLoS_RIS_UE);

disp('Data generated. Saving to benchmark_data.mat...');
save('benchmark_data.mat'); % Save everything
disp('Done.');
