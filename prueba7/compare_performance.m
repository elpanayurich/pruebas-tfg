% compare_performance.m
cwd = pwd;

% --- 1. PREPARE CPU CODE ---
code_cpu = fileread('main1.m');
code_cpu = regexprep(code_cpu, 'clear;', '%clear;'); 
code_cpu = regexprep(code_cpu, 'close all;', '%close all;');
code_cpu = regexprep(code_cpu, 'nbrOfSetups\s*=\s*\d+;', 'nbrOfSetups = 1;');
code_cpu = regexprep(code_cpu, 'nbrOfRealizations\s*=\s*\d+;', 'nbrOfRealizations = 50;');

% --- 2. PREPARE GPU CODE ---
code_gpu = fileread('gpu-testing/main_gpu.m');
code_gpu = regexprep(code_gpu, 'clear;', '%clear;'); 
code_gpu = regexprep(code_gpu, 'close all;', '%close all;');
code_gpu = regexprep(code_gpu, 'nbrOfSetups\s*=\s*\d+;', 'nbrOfSetups = 1;');
code_gpu = regexprep(code_gpu, 'nbrOfRealizations\s*=\s*\d+;', 'nbrOfRealizations = 50;');

disp('================================================');
disp('Starting Performance Comparison (1 Setup, 50 Realizations)');
disp('================================================');

% --- 3. RUN CPU ---
disp('1. Running Original CPU Version...');
try
    cd(cwd);
    t_start = tic;
    eval(code_cpu); 
    time_cpu = toc(t_start);
    disp(['   -> CPU Finished in: ' num2str(time_cpu) ' s']);
catch ME
    disp(['   -> CPU Failed: ' ME.message]);
    disp(ME.stack(1));
    time_cpu = NaN;
end

% --- 4. RUN GPU ---
disp(' ');
disp('2. Running GPU Version...');
try
    cd(fullfile(cwd, 'gpu-testing'));
    t_start = tic;
    eval(code_gpu); 
    time_gpu = toc(t_start);
    disp(['   -> GPU Finished in: ' num2str(time_gpu) ' s']);
catch ME
    disp(['   -> GPU Failed: ' ME.message]);
    disp(ME.stack(1));
    time_gpu = NaN;
end

% --- 5. REPORT ---
cd(cwd);
disp(' ');
disp('================================================');
disp('SUMMARY RESULTS');
if ~isnan(time_cpu) && ~isnan(time_gpu)
    fprintf('Original CPU Time: %6.2f s\n', time_cpu);
    fprintf('Optimized GPU Time:%6.2f s\n', time_gpu);
    fprintf('SPEEDUP:           %6.2f x\n', time_cpu / time_gpu);
end
disp('================================================');
