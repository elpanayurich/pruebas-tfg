masterFig = figure('Color', [0.1 0.1 0.1], 'Name', 'Legend Interactive Plot');
masterAx = axes('Parent', masterFig, 'Color', [0.1 0.1 0.1], ...
    'XColor', [0.8 0.8 0.8], 'YColor', [0.8 0.8 0.8], ...
    'GridColor', [0.5 0.5 0.5], 'GridAlpha', 0.4);
hold(masterAx, 'on');
grid(masterAx, 'on');

figDir = 'figures/square1500m/factor30_tauc10k'; 
dirData = dir(fullfile(figDir, '*.fig'));
if isempty(dirData); error('No .fig files found in %s', figDir); end

figFiles = {dirData.name};
numFiles = length(figFiles);
labels = erase(figFiles, '.fig');

colors = hsv(numFiles);
colors(1, :) = [1 1 1]; 

allLines = gobjects(1, numFiles);

yTargets = 0.1:0.1:0.9;
performanceMatrix = NaN(numFiles, length(yTargets)); 

for i = 1:numFiles
    tempFig = openfig(fullfile(figDir, figFiles{i}), 'invisible');
    srcAx = findobj(tempFig, 'type', 'axes');
    
    if ~isempty(srcAx)
        srcLines = findobj(srcAx(1).Children, 'type', 'line');
        hLine = copyobj(srcLines, masterAx);
        
        set(hLine, 'Color', colors(i,:), 'LineWidth', 1.2, ...
            'DisplayName', labels{i}, ...
            'UserData', colors(i,:)); 
        
        allLines(i) = hLine(1);
        
        [uniqueY, idx] = unique(hLine(1).YData);
        performanceMatrix(i, :) = interp1(uniqueY, hLine(1).XData(idx), yTargets, 'linear', NaN);
    end
    close(tempFig);
end

yTargets = 0.1:0.1:0.9;
fprintf('\n--- Best CDF for each Y value ---\n');
fprintf('%-10s | %-40s | %-10s\n', 'Prob (Y)', 'Best RIS radius', 'Value (X)');
fprintf('-----------|------------------------------------------|-----------\n');

for j = 1:length(yTargets)
    xValuesAtThisY = performanceMatrix(:, j);
    
    [bestX, bestFileIdx] = max(xValuesAtThisY);
    
    if ~isnan(bestX)
        fprintf('  Y = %.1f  | %-40s |  %.4f\n', ...
            yTargets(j), labels{bestFileIdx}, bestX);
    else
        fprintf('  Y = %.1f  | %-40s |  N/A\n', yTargets(j), 'No Data');
    end
end
fprintf('------------------------------------------------------------------\n');
fprintf('Given this results, and analyzing visually, we can see that for a range 0.1-0.35 we\n')
fprintf('should use a RIS radius of 60 meters for ANY given center_grid_factor.\nFor the range 0.35-0.9, we can use a RIS radius\n')
fprintf('of around 130m - 180m, depending on the center_grid_factor. The best mean is 140m since its the\n')
fprintf('distance from any RIS to an AP if the AP is centered.\n')

lgd = legend(allLines, labels, 'Location', 'southoutside', 'NumColumns', 5, ...
    'TextColor', 'w', 'Color', [0.15 0.15 0.15], 'EdgeColor', [0.3 0.3 0.3], ...
    'Interpreter', 'none', 'ItemHitFcn', @(src, event) myLegendCallback(src, event, allLines));

xlabel('X-Axis', 'Color', 'w'); ylabel('Y-Axis', 'Color', 'w');
title('Click Legend Labels to Highlight Lines', 'Color', 'w');

drawnow; 
pause(0.1);
dcm = datacursormode(masterFig);

set(dcm, 'UpdateFcn', @(src, event) myDataCursorCallback(src, event, allLines));

try
    set(dcm, 'Enable', 'on');
catch
    figure(masterFig);
    set(dcm, 'Enable', 'on');
end

hold(masterAx, 'off');


function myLegendCallback(~, event, allLines)
    selectedLine = event.Peer;
    if ~isvalid(selectedLine); return; end
    
    if selectedLine.LineWidth > 2
        set(allLines, 'LineWidth', 1.2);
        for i = 1:length(allLines)
            if isvalid(allLines(i))
                set(allLines(i), 'Color', allLines(i).UserData);
            end
        end
    else
        set(allLines, 'LineWidth', 0.5, 'Color', [0.3 0.3 0.3]);
        set(selectedLine, 'LineWidth', 3, 'Color', selectedLine.UserData);
    end
end

function txt = myDataCursorCallback(~, event_obj, allLines)
    clickedLine = event_obj.Target;
    if ~isvalid(clickedLine); txt = ''; return; end
    
    set(allLines, 'LineWidth', 0.5, 'Color', [0.3 0.3 0.3]);
    set(clickedLine, 'LineWidth', 3, 'Color', clickedLine.UserData);
    
    avgVal = mean(clickedLine.XData, 'omitnan');
    [~, idx] = min(abs(clickedLine.YData - 0.5));
    medVal = clickedLine.XData(idx);
    
    txt = {['FILE: ', clickedLine.DisplayName], ...
           ['Mean:   ', num2str(avgVal, 4)], ...
           ['Median: ', num2str(medVal, 4)]};
end