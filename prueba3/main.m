close all;
clear;

%% Deploy simulation environment 
%Set the side length of the simulation area
squareLength = 400;

%Number of APs and number of antenas for each AP
L = 64;
N = 1;

%Number of UEs in the simulation setup and number of setups
K = 10;
nbrOfSetups = 1;

%General settings
fc = 3.5;

%Set the AP and UE locations 
[APlocations, UElocations] = env_setup(K, L, squareLength, nbrOfSetups);

%Channel calculation
[H_AP_UE] = channel_calculation(K, L, N, nbrOfSetups, fc, APlocations, UElocations);

%% Plot simulation results
