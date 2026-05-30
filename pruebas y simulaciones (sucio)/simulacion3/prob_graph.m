h_ut = 1.5;
h_ris = 10;
distancias = 1:1000;

prob_AP_UE = zeros(1, 1000);
prob_AP_RIS = zeros(1, 1000);

% AP-UE (RIS-UE deberia ser igual a esta)
for d = distancias
    if h_ut > 4.5
        C = ((h_ut - 4.5)/10)^1.5;
    else
        C = 0;
    end
    
    if d > 18
        term1 = (18./d) + exp(-d./63) .* (1 - (18./d));
        term2 = 1 + C * (5/4) * ((d./100).^3) .* exp(-d./150);
        prob_AP_UE(d) = term1 .* term2; 
    else
        prob_AP_UE(d) = 1;
    end
end

% AP-RIS
for d = distancias
    if h_ris > 2
        C = ((h_ris - 2)/10)^1.5;
    else
        C = 0;
    end
    
    if d > 18
        term1 = (18./d) + exp(-d./63) .* (1 - (18./d));
        term2 = 1 + C * (5/4) * ((d./100).^3) .* exp(-d./150);
        prob_AP_RIS(d) = term1 .* term2; 
    else
        prob_AP_RIS(d) = 1;
    end
end


figure;
plot(distancias, prob_AP_UE, 'LineWidth', 2, 'Color', 'b'); 
hold on;
plot(distancias, prob_AP_RIS, 'LineWidth', 2, 'Color', 'r', 'LineStyle', '--');
hold off;
grid on;
title('Comparación Probabilidad LoS: UE vs RIS');
xlabel('Distancia (metros)');
ylabel('Probabilidad LoS');
ylim([0 1.1]);
xlim([0 1000]);
legend(['UE (h = ' num2str(h_ut) ' m)'], ['RIS (h = ' num2str(h_ris) ' m)']);