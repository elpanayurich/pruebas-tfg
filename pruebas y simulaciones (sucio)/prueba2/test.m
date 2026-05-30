close all;
clear;

%Set the side length of the simulation area
squareLength = 400;

%Total number of antennas (APs) in cell-free setup
nbrOfAntennas = 64;

%Set the AP locations for the cell-free setups
APperdim = sqrt(nbrOfAntennas);
APcellfree = linspace(squareLength/APperdim,squareLength,APperdim)-squareLength/APperdim/2;
APcellfree = repmat(APcellfree,[APperdim 1]) + 1i*repmat(APcellfree,[APperdim 1])';

%Number of realizations of the random UE locations
nbrOfSetups = 100000;

%Number of UEs in the simulation setup
K = 8;

%Generate the random UE locations for all setups
UElocations = (rand(nbrOfSetups,K)+1i*rand(nbrOfSetups,K))*squareLength;

%Define a function to compute the SNR as function of the horizontal distance
%measured in meter. The AP is 10 meter above the UE.
SNR = @(hor_dist) db2pow(10+96-30.5-36.7*log10(sqrt(hor_dist.^2+10^2)));

%Prepare to store simulation results
SINR_cellfree = zeros(nbrOfSetups,K);


%% Go through all random realizations of the UE locations
for n = 1:nbrOfSetups
    
    %Generate the channel matrix in the cell-free setup
    channelCellfree = zeros(nbrOfAntennas,K);
    
    for k = 1:K
        distanceCellfree = abs(APcellfree(:) - UElocations(n,k));
        channelCellfree(:,k) = sqrt(SNR(distanceCellfree)).*exp(1i*2*pi*rand(nbrOfAntennas,1));  %[Se genera una fase aleatoria para cada AP]
    end
    
    %Compute the SINR when using MMSE combining
    SINR_cellfree(n,:) = computeSINRs_MMSE(channelCellfree);
    
end


%% Plot simulation results
figure;
hold on; box on;
plot(pow2db(sort(SINR_cellfree(:),'ascend')),linspace(0,1,nbrOfSetups*K),'b--','LineWidth',2);
xlabel('SINR [dB]','Interpreter','latex');
ylabel('CDF','Interpreter','latex');
legend({'Cell-free'},'Interpreter','latex','Location','SouthEast');
set(gca,'fontsize',16);
xlim([0 60]);
