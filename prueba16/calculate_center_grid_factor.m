function [calculated_center_grid_factor] = calculate_center_grid_factor(APpositions, L, squareLength)
    % Con está función calculamos el factor de centrado dadas las
    % posiciones de los APs. Conseguimos
    APperdim = sqrt(L);
    APpositions_centered = zeros (APperdim);
    grid_long = squareLength/(APperdim);
    center = grid_long/2;
    count_f = 1i*0;
    for i = 1:APperdim
        count_c = 0;
        for j = 1:APperdim
            APpositions_centered(i, j) = center + 1i*center + count_c + count_f;
            count_c = count_c + grid_long;
        end
        count_f = count_f + 1i*grid_long;
    end
    APpositions_centered = reshape(APpositions_centered, L, 1);

    delta = APpositions_centered - APpositions;
    distancias = [abs(real(delta)); abs(imag(delta))];
    calculated_center_grid_factor = (mean(distancias) * 2) / (center);
end
