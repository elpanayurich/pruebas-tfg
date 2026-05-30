%factors = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.8, 0.9, 1.0];
factors = [0.7, 1.0];
%squares = [250, 375, 500, 625, 750, 875, 1125, 1250, 1375, 1500];
squares = [2000];
%factors = [0, 0.3, 0.7, 1.0];
for squ = 1:length(squares)
    for f = 1:length(factors)
        center_grid_factor = factors(f);
        increment = -10;
        
        for s = 1:30
            clearvars -except variable increment factors f s center_grid_factor squ squares;
            increment = increment + 10;
            RIS_radius = increment;
            squareLength = squares(squ);
            main1;
        end
       
        grid_val = center_grid_factor * 100;
        folderName = sprintf('figures/square%dm/factor%.0f_tauc10k', squares(squ), grid_val);
        
        if ~exist(folderName, 'dir')
            mkdir(folderName);
        end
        
        movefile('figures/*.fig', folderName);
        fprintf('Finished and moved files to: %s\n', folderName);
    end
end
