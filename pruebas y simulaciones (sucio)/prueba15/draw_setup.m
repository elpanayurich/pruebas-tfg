function draw_setup(APpositions, RISpositions, UEpositions)
    xAP = real(APpositions(:));
    yAP = imag(APpositions(:));
    xRIS = real(RISpositions(:));
    yRIS = imag(RISpositions(:));
    xUE = real(UEpositions(:));
    yUE = imag(UEpositions(:));

    figure;
    hold on; grid on;
    scatter(xAP, yAP, '^', 'filled', 'b');
    scatter(xRIS, yRIS, 's', 'filled', 'g');
    scatter(xUE, yUE, 'o', 'filled', 'r');
    title('Position setup - APs, UEs, RIS');
    xlabel('x [m]');
    ylabel('y [m]');
    legend('APs', 'RIS', 'UEs', 'Location', 'bestoutside');
    axis equal;
    hold off;
end

