% 1. Setup the master figure
masterFig = figure;
masterAx = axes('Parent', masterFig);
hold(masterAx, 'on');

% 2. Define filenames and your desired labels/colors
figFiles = {'fig1.fig', 'fig2.fig', 'fig3.fig'};
labels = {'Normal', 'ALL', 'Random'};
colors = {'#D95319', '#0072BD', '#7E2F8E'}; % Using hex for modern colors

% This array will store handles for the legend
legendHandles = gobjects(1, length(figFiles));

for i = 1:length(figFiles)
    % Open source figure hidden
    tempFig = openfig(figFiles{i}, 'invisible');
    srcAx = findobj(tempFig, 'type', 'axes');
    
    % Copy data to master axes
    objs = copyobj(srcAx.Children, masterAx);
    
    % Apply color and store the first handle for the legend
    % (Useful if one figure contains multiple lines)
    set(objs, 'Color', colors{i}, 'LineWidth', 1.5);
    legendHandles(i) = objs(1); 
    
    close(tempFig);
end

% 3. Finalize plot styling
legend(legendHandles, labels, 'Location', 'best');
xlabel('X-Axis Title');
ylabel('Y-Axis Title');
title('Combined Data Overlay');
grid on;
hold(masterAx, 'off');