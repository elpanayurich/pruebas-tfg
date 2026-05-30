close all;
clear;

%Set the side length of the simulation area
squareLength = 400;

%Total number of antennas in all setups
nbrOfAntennas = 64;

%Set the AP location of the cellular Massive MIMO setup
APcellular = squareLength/2 + 1i*squareLength/2;

%Set the AP locations for the small-cell and cell-free setups
APperdim = sqrt(nbrOfAntennas);
%APcellfree = linspace(squareLength/APperdim,squareLength,APperdim)-squareLength/APperdim/2;
%APcellfree = repmat(APcellfree,[APperdim 1]) + 1i*repmat(APcellfree,[APperdim 1])';
APcellfree = zeros (APperdim);
count_f = 1i*0;

for i = 1:APperdim
    count_c = 0;
    for j = 1:APperdim
        APcellfree(i, j) = randi([0, 50]) + 1i*(randi([0, 50])) + count_c + count_f;
        count_c = count_c + 50;
    end
    count_f = count_f + 1i*50;
end

%Number of realizations of the random UE locations
nbrOfSetups = 100000;

%Number of UEs in the simulation setup
K = 1;

%Generate the random UE locations for all setups
UElocations = (rand(nbrOfSetups,K)+1i*rand(nbrOfSetups,K))*squareLength;

%Define a function to compute the SNR as function of the horizontal distance 
%measured in meter. The AP is 10 meter above the UE.
SNR = @(hor_dist) db2pow(10+96-30.5-36.7*log10(sqrt(hor_dist.^2+10^2)));


%Prepare to store simulation results
SINR_cellular_mMIMO = zeros(nbrOfSetups,K);
SINR_cellular_small = zeros(nbrOfSetups,K);
SINR_cellfree = zeros(nbrOfSetups,K);



%% Go through all random realizations of the UE locations
for n = 1:nbrOfSetups

    %Generate the channel matrix in the cellular Massive MIMO setup
    channelCellular = zeros(nbrOfAntennas,K);
    
    for k = 1:K
        distanceCellular = abs(APcellular - UElocations(n,k));
        channelCellular(:,k) = sqrt(SNR(distanceCellular))*exp(1i*2*pi*rand(nbrOfAntennas,1));
    end
    
    %Compute the SINR when using MMSE combining
    SINR_cellular_mMIMO(n,:) = computeSINRs_MMSE(channelCellular);
    
    
    %Generate the channel matrix in the cell-free setup
    channelCellfree = zeros(nbrOfAntennas,K);
    
    for k = 1:K
        distanceCellfree = abs(APcellfree(:) - UElocations(n,k));
        channelCellfree(:,k) = sqrt(SNR(distanceCellfree)).*exp(1i*2*pi*rand(nbrOfAntennas,1));
    end
    
    %Compute the SINR when using MMSE combining
    SINR_cellfree(n,:) = computeSINRs_MMSE(channelCellfree);
    
    
    %Compute all the possible SINRs in the small-cell setup
    SINRs_smallcells = zeros(nbrOfAntennas,K);
    
    for m = 1:nbrOfAntennas
        
        SINRs_smallcells(m,:) = computeSINRs_MMSE(channelCellfree(m,:)); 
        
    end
    
    %Assign each UE to the AP providing the largest SINR
    SINR_cellular_small(n,:) = max(SINRs_smallcells,[],1);
    
end


%% Plot simulation results
figure;
hold on; box on;
plot(pow2db(sort(SINR_cellfree(:),'ascend')),linspace(0,1,nbrOfSetups*K),'b--','LineWidth',2);
plot(pow2db(sort(SINR_cellular_small(:),'ascend')),linspace(0,1,nbrOfSetups*K),'r-.','LineWidth',2);
plot(pow2db(sort(SINR_cellular_mMIMO(:),'ascend')),linspace(0,1,nbrOfSetups*K),'k','LineWidth',2);
xlabel('SNR [dB]','Interpreter','latex');
ylabel('CDF','Interpreter','latex');
legend({'Cell-free','Cellular: Small cells','Cellular: Massive MIMO'},'Interpreter','latex','Location','SouthEast');
set(gca,'fontsize',16);
xlim([0 60]);
