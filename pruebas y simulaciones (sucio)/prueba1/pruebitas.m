close all;
clear;

APperdim = 8;
APcellfree = zeros (APperdim);

count_f = 1i*0;
for i = 1:APperdim
    count_c = 0;
    for j = 1:APperdim
        APcellfree(i, j) = randi([0, 50]) + 1i*(randi([0, 50])) + count_c + count_f;
        count_c = count_c + 50;
    end
    count_f = count_f + 1i*50;
end