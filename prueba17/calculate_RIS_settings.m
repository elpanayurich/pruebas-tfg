function [best_radius] = calculate_RIS_settings(center_grid_factor, user_percentage)
    data = load('best_radius_results.mat');
    factor = center_grid_factor * 100;
    [~, rowIdx] = min(abs(data.factors - factor))
    [~, colIdx] = min(abs(data.yTargets - user_percentage))
    best_radius = data.radiusMatrix(rowIdx, colIdx);
end