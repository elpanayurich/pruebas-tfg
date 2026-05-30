clear; clc;
baseDir = 'figures';
squares = [250, 375, 500, 625, 750, 875, 1000, 1125, 1250, 1375, 1500, 1750, 2000];
factors = 0:10:100; 
yTargets = 0.1:0.1:0.9;

bestMeanRadii = NaN(1, length(squares));
best90Radii = NaN(1, length(squares));

for sIdx = 1:length(squares)
    squVal = squares(sIdx);
    squareFolderName = sprintf('square%dm', squVal);
    fprintf('\n==========================================\n');
    fprintf(' ANALYZING: %s\n', squareFolderName);
    fprintf('==========================================\n');
    
    radiusMatrix = NaN(length(factors), length(yTargets)); 
    allBestRISValues = []; 
    for fIdx = 1:length(factors)
        f = factors(fIdx);
        figDir = fullfile(baseDir, squareFolderName, sprintf('factor%d_tauc10k', f));
        
        if ~exist(figDir, 'dir'); continue; end
        dirData = dir(fullfile(figDir, '*.fig'));
        if isempty(dirData); continue; end
        
        figFiles = {dirData.name};
        labels = erase(figFiles, '.fig');
        performanceMatrix = NaN(length(figFiles), length(yTargets)); 
        meansList = NaN(1, length(figFiles));
        
        for i = 1:length(figFiles)
            tempFig = openfig(fullfile(figDir, figFiles{i}), 'invisible');
            hLine = findobj(tempFig, 'type', 'line');
            
            if ~isempty(hLine)
                [uniqueY, idx] = unique(hLine(1).YData);
                performanceMatrix(i, :) = interp1(uniqueY, hLine(1).XData(idx), yTargets, 'linear', NaN);
                meansList(i) = mean(hLine(1).XData, 'omitnan');
            end
            close(tempFig);
        end
        
        for j = 1:length(yTargets)
            [~, bestIdx90] = max(performanceMatrix(:, j));
            val90 = regexp(labels{bestIdx90}, 'RIS(\d+)', 'tokens');
            if ~isempty(val90)
                radiusMatrix(fIdx, j) = str2double(val90{1}{1}); 
            end
        end
        
        [~, bestIdxMean] = max(meansList);
        valMean = regexp(labels{bestIdxMean}, 'RIS(\d+)', 'tokens');
        if ~isempty(valMean)
            allBestRISValues(end+1) = str2double(valMean{1}{1});
        end
    end
    
    if ~isempty(allBestRISValues)
        firstColumn = radiusMatrix(:, 1);
        mostRepeated90 = mode(firstColumn);
        avgBestMean = mean(allBestRISValues);
        
        bestMeanRadii(sIdx) = avgBestMean;
        best90Radii(sIdx) = mostRepeated90;
        
        fprintf('best mean radius: %.2f\n', avgBestMean);
        fprintf('best radius 90%% of users: %.2f\n', mostRepeated90);
    else
        fprintf('no data found\n');
    end
end

sqFine = linspace(min(squares), max(squares), 300);

fig1 = figure('Name', 'Best Mean Radius', 'Color', [0.1 0.1 0.1]); 
ax1 = axes('Parent', fig1, 'Color', [0.15 0.15 0.15], 'XColor', 'w', 'YColor', 'w'); 
hold(ax1, 'on');

meanInterp = interp1(squares, bestMeanRadii, sqFine, 'makima'); 

plot(ax1, squares, bestMeanRadii, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8, 'DisplayName', 'Calculated Means'); 
plot(ax1, sqFine, meanInterp, 'Color', [0 0.8 1], 'LineWidth', 2, 'DisplayName', 'Interpolated');

grid(ax1, 'on'); ax1.GridColor = [0.5 0.5 0.5]; ax1.GridAlpha = 0.3;
xlabel(ax1, 'Square Size (m)', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'w');
ylabel(ax1, 'Best Mean Radius', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'w');
title(ax1, 'Best Mean Radius vs Square Size', 'Color', 'w');
legend(ax1, 'TextColor', 'w', 'EdgeColor', 'w', 'Location', 'northwest');

fig2 = figure('Name', 'Best Radius 90% Users', 'Color', [0.1 0.1 0.1]);
ax2 = axes('Parent', fig2, 'Color', [0.15 0.15 0.15], 'XColor', 'w', 'YColor', 'w');
hold(ax2, 'on');

r90Interp = interp1(squares, best90Radii, sqFine, 'makima');

plot(ax2, squares, best90Radii, 'yo', 'MarkerFaceColor', 'y', 'MarkerSize', 8, 'DisplayName', '90% Radius Points'); 
plot(ax2, sqFine, r90Interp, 'Color', [0 1 0.5], 'LineWidth', 2, 'DisplayName', 'Interpolated');

grid(ax2, 'on'); ax2.GridColor = [0.5 0.5 0.5]; ax2.GridAlpha = 0.3;
xlabel(ax2, 'Square Size (m)', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'w');
ylabel(ax2, 'Best Radius 90%', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'w');
title(ax2, 'Best Radius (90% Users) vs Square Size', 'Color', 'w');
legend(ax2, 'TextColor', 'w', 'EdgeColor', 'w', 'Location', 'northwest');