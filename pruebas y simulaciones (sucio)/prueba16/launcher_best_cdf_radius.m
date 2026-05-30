clear; clc;

factors = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]; 
yTargets = 0.1:0.1:0.9;
baseDir = 'figures';

radiusMatrix = NaN(length(factors), length(yTargets)); 

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
    
    for j = 1:length(yTargets)
        [~, bestIdx] = max(performanceMatrix(:, j));
        val = regexp(labels{bestIdx}, 'RIS(\d+)m', 'tokens');
        if ~isempty(val)
            radiusMatrix(fIdx, j) = str2double(val{1}{1}); 
        end
    end
    fprintf('Done: Factor %d\n', f);
end

fprintf('Result: radiusMatrix (Rows=Factors, Cols=Y)\n');
disp(radiusMatrix);