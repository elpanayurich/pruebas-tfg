%% Unified CDF Batch Processor (Numeric Array Storage)
clear; clc;

% --- Configuration ---
factors = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]; 
yTargets = 0.1:0.1:0.9;
baseDir = 'figures';

% Pre-allocate numeric matrix (Rows: Factors, Cols: Y-Probabilities)
radiusMatrix = NaN(length(factors), length(yTargets)); 

fprintf('Processing folders...\n');

for fIdx = 1:length(factors)
    f = factors(fIdx);
    figDir = fullfile(baseDir, sprintf('factor%d_tauc10k', f));
    
    if ~exist(figDir, 'dir'); continue; end
    
    dirData = dir(fullfile(figDir, '*.fig'));
    if isempty(dirData); continue; end
    
    figFiles = {dirData.name};
    labels = erase(figFiles, '.fig');
    performanceMatrix = NaN(length(figFiles), length(yTargets)); 
    
    for i = 1:length(figFiles)
        tempFig = openfig(fullfile(figDir, figFiles{i}), 'invisible');
        srcAx = findobj(tempFig, 'type', 'axes');
        if ~isempty(srcAx)
            srcLines = findobj(srcAx(1).Children, 'type', 'line');
            if ~isempty(srcLines)
                [uniqueY, idx] = unique(srcLines(1).YData);
                performanceMatrix(i, :) = interp1(uniqueY, srcLines(1).XData(idx), yTargets, 'linear', NaN);
            end
        end
        close(tempFig);
    end
    
    % Extract numeric radius and store in the matrix
    for j = 1:length(yTargets)
        [~, bestIdx] = max(performanceMatrix(:, j));
        % Extract digits from 'RIS180m' -> 180
        val = regexp(labels{bestIdx}, 'RIS(\d+)m', 'tokens');
        if ~isempty(val)
            radiusMatrix(fIdx, j) = str2double(val{1}{1}); 
        end
    end
    fprintf('Done: Factor %d\n', f);
end

% --- Final Display ---
fprintf('\nOVERALL SUMMARY: radiusMatrix (Rows=Factors, Cols=Y)\n');
disp(radiusMatrix);

% --- Example Extraction Logic ---
fprintf('\n--- Extraction Examples ---\n');
% If you want Factor 70 (which is the 8th row in our 'factors' array) 
% and Y = 0.5 (which is the 5th column)
rowIdx = find(factors == 70);
colIdx = find(yTargets == 0.5);
result = radiusMatrix(rowIdx, colIdx);

fprintf('Best Radius for Factor %d at Y=%.1f is: %d meters\n', ...
    factors(rowIdx), yTargets(colIdx), result);