% Debug script to check return types
clear; clc;

L = 16; K = 10; S = 25;
probLoS_AP_UE = rand(L, K);
probLoS_RIS_UE = rand(S, K);

disp('--- Testing assignRIS_All ---');
try
    r1 = assignRIS_All(probLoS_AP_UE, probLoS_RIS_UE);
    disp(['Class: ' class(r1)]);
    disp(['Size: ' num2str(size(r1))]);
    disp(['First element type: ' class(r1{1})]);
catch ME
    disp(['Error: ' ME.message]);
end

disp('--- Testing assignRIS ---');
try
    r2 = assignRIS(probLoS_AP_UE, probLoS_RIS_UE);
    disp(['Class: ' class(r2)]);
    disp(['Size: ' num2str(size(r2))]);
    if iscell(r2) && ~isempty(r2)
        disp(['First element type: ' class(r2{1})]);
    else
        disp('Not a cell or empty');
    end
catch ME
    disp(['Error: ' ME.message]);
end

disp('--- Testing Random Logic ---');
try
    r3 = num2cell(randi(K, S, 1));
    disp(['Class: ' class(r3)]);
    disp(['Size: ' num2str(size(r3))]);
    disp(['First element type: ' class(r3{1})]);
catch ME
    disp(['Error: ' ME.message]);
end
