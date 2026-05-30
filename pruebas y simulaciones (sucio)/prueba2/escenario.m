function [APlocations, UElocations] = escenario(APperdim, squareLength, K, nbrOfSetups)

    %Set the AP locations
    APlocations = zeros (APperdim);
    count_f = 1i*0;
    for i = 1:APperdim
        count_c = 0;
        for j = 1:APperdim
            APlocations(i, j) = randi([10, 40]) + 1i*(randi([10, 40])) + count_c + count_f;
            %APlocations(i, j) = 25 + 1i*25 + count_c + count_f;
            count_c = count_c + 50;
        end
        count_f = count_f + 1i*50;
    end

    %Set the UE locations
    UElocations = zeros(nbrOfSetups, K);
    for i= 1:nbrOfSetups
        for j = 1:K
            UElocations(i, j) = randi([0, squareLength]) + 1i*randi([0, squareLength]);
        end
    end
    
    %Draw
    xAP = real(APlocations(:));
    yAP = imag(APlocations(:));
    xUE = real(UElocations(1, :));
    yUE = imag(UElocations(1, :));

    figure;
    hold on;
    
    % APs como triángulos
    scatter(xAP, yAP, '^', 'filled', 'b');
    
    % UEs como círculos
    scatter(xUE, yUE, 'o', 'filled', 'r');
    
    title('Posición de los AP y UEs en el plano');
    xlabel('x [m]');
    ylabel('y [m]');
    legend('APs', 'UEs', 'Location', 'bestoutside');
    grid on;
    axis equal;
    xlim([0 squareLength]);
    ylim([0 squareLength]);
    hold off;

end