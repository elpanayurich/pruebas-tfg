close all;
clear;

%Set the side length of the simulation area
squareLength = 400;

%Total number of antennas in all setups
nbrOfAntennas = 64;

%Number of UEs in the simulation setup and number of setups
K = 10;
nbrOfSetups = 100;

%Set the AP and UE locations 
APperdim = sqrt(nbrOfAntennas);
[APlocations, UElocations] = escenario(APperdim, squareLength, K, nbrOfSetups);

%Define a function to compute the SNR as function of the horizontal distance 
%measured in meter. The AP is 10 meter above the UE.
SNR = @(hor_dist) db2pow(10+96-30.5-36.7*log10(sqrt(hor_dist.^2+10^2)));
SINR= zeros(1, K);


for n = 1:nbrOfSetups

    %Generate the channel matrix in the cell-free setup
    channel = zeros(nbrOfAntennas,K);
    for k = 1:K
        distance = abs(APlocations(:) - UElocations(n,k));
        channel(:,k) = sqrt(SNR(distance)).*exp(1i*2*pi*rand(nbrOfAntennas,1));
    end
    
    %Compute the SINR when using MMSE combining
    SINR(n,:) = computeSINRs_MMSE(channel);

end

%% Plot simulation results
figure;
hold on; box on;
plot(pow2db(sort(SINR(:),'ascend')),linspace(0,1,nbrOfSetups*K),'b--','LineWidth',2);
xlabel('SNR [dB]','Interpreter','latex');
ylabel('CDF','Interpreter','latex');
set(gca,'fontsize',16);
xlim([0 60]);