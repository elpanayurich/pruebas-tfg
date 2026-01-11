% 1. Setup the master figure
masterFig = figure;
masterAx = axes('Parent', masterFig);
hold(masterAx, 'on');

% 2. Identify all .fig files in the directory
figDir = 'figures/';
filePattern = fullfile(figDir, '*.fig');
dirData = dir(filePattern);

if isempty(dirData)
    error('No .fig files found in the specified directory: %s', figDir);
end

% Extract filenames and create labels
figFiles = {dirData.name};
% Remove '.fig' extension for the labels
labels = erase(figFiles, '.fig');

% Define a color palette (Matlab's default order or a custom list)
% 'lines' generates a colormap with distinct colors for any number of files
colors = lines(length(figFiles));

% This array will store handles for the legend
legendHandles = gobjects(1, length(figFiles));

for i = 1:length(figFiles)
    % Open source figure hidden
    fullPath = fullfile(figDir, figFiles{i});
    tempFig = openfig(fullPath, 'invisible');
    srcAx = findobj(tempFig, 'type', 'axes');
    
    % Copy data to master axes
    % We use [1] in case there are multiple axes; usually fig files have one.
    objs = copyobj(srcAx(1).Children, masterAx);
    
    % Apply color and store the first handle for the legend
    % Note: If your figures contain non-line objects (like surfaces), 
    % you might need to check the object type before setting 'Color'.
    set(objs, 'Color', colors(i, :), 'LineWidth', 1.5);
    
    % Store the handle of the first object from this file for the legend
    legendHandles(i) = objs(1); 
    
    close(tempFig);
end

% 3. Finalize plot styling
legend(legendHandles, labels, 'Location', 'best', 'Interpreter', 'none');
xlabel('X-Axis Title');
ylabel('Y-Axis Title');
title('Combined Data Overlay');
grid on;
hold(masterAx, 'off');