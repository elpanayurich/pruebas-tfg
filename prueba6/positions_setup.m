function [APpositions, RISpositions, UEpositions, wrapLocations, APpositionsWrapped] = positions_setup(L, K, squareLength, center_grid_factor)
    
    % Posiciones aleatorias de los APs con distribución uniforme
    %APpositions = (rand(L,1) + 1i*rand(L,1)) * squareLength;

    %Posiciones de los APs en un grid
    APperdim = sqrt(L);
    APpositions = zeros (APperdim);
    grid_long = squareLength/(APperdim);
    center = grid_long/2;
    center_grid_down = round(center * (1 - center_grid_factor));
    center_grid_up = round(center * (1 + center_grid_factor));
    count_f = 1i*0;
    for i = 1:APperdim
        count_c = 0;
        for j = 1:APperdim
            %APpositions(i, j) = center + 1i*center + count_c + count_f;
            APpositions(i, j) = randi([center_grid_down, center_grid_up]) + 1i*(randi([center_grid_down, center_grid_up])) + count_c + count_f; 
            count_c = count_c + grid_long;
        end
        count_f = count_f + 1i*grid_long;
    end
    APpositions = reshape(APpositions, L, 1);

    % Posiciones aleatorias de las RIS con distribución uniforme
    %RISpositions = (rand(S,1) + 1i*rand(S,1)) * squareLength;

    %Posiciones de las RIS en las esquinas del grid
    RISperdim = sqrt(L) + 1;
    RISpositions = zeros (RISperdim);
    center = 0;
    count_f = 1i*0;
    for i = 1:RISperdim
        count_c = 0;
        for j = 1:RISperdim
            RISpositions(i, j) = center + 1i*center + count_c + count_f;
            count_c = count_c + grid_long;
        end
        count_f = count_f + 1i*grid_long;
    end
    RISpositions = reshape(RISpositions, (RISperdim^2), 1);


    % Posiciones de los usuarios (UEs)
    UEpositions = zeros(K,1);
    for i = 1:K
        UEpositions(i) = randi([0, squareLength]) + 1i*randi([0, squareLength]);
    end
        
    % Calcular ubicaciones alternativas de los APs con wraparound
    wrapHorizontal = repmat([-squareLength 0 squareLength],[3 1]);
    wrapVertical = wrapHorizontal';
    wrapLocations = wrapHorizontal(:)' + 1i*wrapVertical(:)';
    APpositionsWrapped = repmat(APpositions,[1 length(wrapLocations)]) + repmat(wrapLocations,[L 1]);
end

