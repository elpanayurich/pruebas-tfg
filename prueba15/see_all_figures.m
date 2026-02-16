%% 1. Setup Dark Master Figure
masterFig = figure('Color', [0.1 0.1 0.1], 'Name', 'Legend Interactive Plot');
masterAx = axes('Parent', masterFig, 'Color', [0.1 0.1 0.1], ...
    'XColor', [0.8 0.8 0.8], 'YColor', [0.8 0.8 0.8], ...
    'GridColor', [0.5 0.5 0.5], 'GridAlpha', 0.4);
hold(masterAx, 'on');
grid(masterAx, 'on');

%% 2. File Identification
figDir = 'figures/factor100_tauc10k'; 
dirData = dir(fullfile(figDir, '*.fig'));
if isempty(dirData); error('No .fig files found in %s', figDir); end

figFiles = {dirData.name};
numFiles = length(figFiles);
labels = erase(figFiles, '.fig');

%% 3. Color Palette
colors = hsv(numFiles);
colors(1, :) = [1 1 1]; 

allLines = gobjects(1, numFiles);

%% 4. Import and Tag Lines
meansList = zeros(1, numFiles); % Pre-allocate for performance

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
        
        % Calculate mean for this specific file
        meansList(i) = mean(hLine(1).XData, 'omitnan');
    end
    close(tempFig);
end

%% 4.5 Identify and Print "Best" Mean
% Assuming "better" mean is the highest value. 
% (If lower is better for your data, use min instead of max)
[bestVal, bestIdx] = max(meansList); 

fprintf('\n--- Performance Summary ---\n');
fprintf('The file with the best mean is: **%s**\n', labels{bestIdx});
fprintf('Value: %.4f\n', bestVal);
fprintf('---------------------------\n');

%% 5. Create Interactive Legend
lgd = legend(allLines, labels, 'Location', 'southoutside', 'NumColumns', 5, ...
    'TextColor', 'w', 'Color', [0.15 0.15 0.15], 'EdgeColor', [0.3 0.3 0.3], ...
    'Interpreter', 'none', 'ItemHitFcn', @(src, event) myLegendCallback(src, event, allLines));

xlabel('X-Axis', 'Color', 'w'); ylabel('Y-Axis', 'Color', 'w');
title('Click Legend Labels to Highlight Lines', 'Color', 'w');

%% 6. Data Cursor (Fixed Error Logic)
drawnow; 
pause(0.1); % Give the UI a millisecond to breathe
dcm = datacursormode(masterFig);

% Ensure we are targeting the right figure explicitly
set(dcm, 'UpdateFcn', @(src, event) myDataCursorCallback(src, event, allLines));

try
    % This is the line that usually crashes; wrapping in try/catch 
    % prevents the whole script from failing if the toolbar is cranky.
    set(dcm, 'Enable', 'on');
catch
    % Fallback: Force focus and try one last time
    figure(masterFig);
    set(dcm, 'Enable', 'on');
end

hold(masterAx, 'off');

%% --- HELPER FUNCTIONS ---

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
    
    % Visual Highlight
    set(allLines, 'LineWidth', 0.5, 'Color', [0.3 0.3 0.3]);
    set(clickedLine, 'LineWidth', 3, 'Color', clickedLine.UserData);
    
    % Stats
    avgVal = mean(clickedLine.XData, 'omitnan');
    [~, idx] = min(abs(clickedLine.YData - 0.5));
    medVal = clickedLine.XData(idx);
    
    txt = {['FILE: ', clickedLine.DisplayName], ...
           ['Mean:   ', num2str(avgVal, 4)], ...
           ['Median: ', num2str(medVal, 4)]};
end