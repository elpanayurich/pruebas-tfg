\factors = [0.2, 0.3, 0.4, 0.6, 0.7, 0.8, 0.9, 1.0];
squares = [1000];

% Selector de modo de asignacion: 'shared' (por defecto) o 'exclusive' (1 RIS max por UE)
assignment_mode = 'exclusive'; 

for squ = 1:length(squares)
    for f = 1:length(factors)
        center_grid_factor = factors(f);
        increment = 100;
        
        for s = 1:19
            clearvars -except variable increment factors f s center_grid_factor squ squares assignment_mode;
            increment = increment + 10;
            RIS_radius = increment;
            squareLength = squares(squ);
            main1;
        end
       
        grid_val = center_grid_factor * 100;
        folderName = sprintf('figures/square%dm/factor%.0f_tauc10k_%s', squares(squ), grid_val, assignment_mode);
        origenName = sprintf('figures/square%dm/factor%.0f_tauc10k', squares(squ), grid_val);
        
        if ~exist(folderName, 'dir')
            mkdir(folderName);
        end
        
        % Mover las generadas en esta iteracion (110 a 290)
        movefile('figures/*.fig', folderName);
        
        % Copiar de 0 a 100m desde la carpeta no exclusiva
        for i = 0:10:100
            f_orig = fullfile(origenName, sprintf('GridFactor%.0f_RIS%dm_AP31m.fig', grid_val, i));
            if exist(f_orig, 'file')
                copyfile(f_orig, folderName);
            end
        end
        
        fprintf('Finished and moved/copied files to: %s\n', folderName);
    end
end
