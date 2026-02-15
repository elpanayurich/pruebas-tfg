factors = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.8, 0.9, 1.0];

for f = 1:length(factors)
    center_grid_factor = factors(f);
    increment = -10;
    for s = 1:30
        clearvars -except variable increment factors f s center_grid_factor;
        increment = increment + 10;
        RIS_radius = increment;
        main1; 
    end
    grid_val = center_grid_factor * 100;
    folderName = sprintf('figures/factor%.0f_tauc10k', grid_val);
    movefile('figures/*.fig', folderName);
    fprintf('Finished and moved files for factor: %.1f\n', center_grid_factor);
end