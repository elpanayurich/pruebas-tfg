function [best_radius] = calculate_RIS_settings(center_grid_factor, user_percentage)
    data = load('best_radius_results.mat');
    [~, rowIdx] = min(abs(data.factors - center_grid_factor));
    [~, colIdx] = min(abs(data.yTargets - user_percentage));
    best_radius = data.radiusMatrix(rowIdx, colIdx);
end