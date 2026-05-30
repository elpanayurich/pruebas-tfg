function speed_diff()
    % speed_diff.m
    % Benchmarks prueba6/main1.m vs prueba8/main_gpu.m by creating temporary
    % copies without 'clear' commands to preserve timing variables.

    currentDir = pwd;
    
    fprintf('Preparing to benchmark...\n');

    % --- Benchmark CPU (prueba6/main1.m) ---
    fprintf('\nRunning prueba6/main1.m (CPU)...\n');
    cd('prueba6');
    try
        time_cpu = run_safe('main1.m');
        fprintf('CPU time: %.4f seconds\n', time_cpu);
    catch ME
        fprintf('Error running prueba6/main1.m: %s\n', ME.message);
        time_cpu = NaN;
    end
    cd(currentDir);

    % --- Benchmark GPU (prueba8/main_gpu.m) ---
    fprintf('\nRunning prueba8/main_gpu.m (GPU)...\n');
    cd('prueba8');
    try
        time_gpu = run_safe('main_gpu.m');
        fprintf('GPU time: %.4f seconds\n', time_gpu);
    catch ME
        fprintf('Error running prueba8/main_gpu.m: %s\n', ME.message);
        time_gpu = NaN;
    end
    cd(currentDir);

    % --- Results ---
    if ~isnan(time_cpu) && ~isnan(time_gpu)
        time_diff = time_cpu - time_gpu;
        speedup = time_cpu / time_gpu;
        
        fprintf('\n--- Benchmark Results ---\n');
        fprintf('CPU Time: %.4f s\n', time_cpu);
        fprintf('GPU Time: %.4f s\n', time_gpu);
        fprintf('Time Difference: %.4f s\n', time_diff);
        
        if time_diff > 0
            fprintf('GPU version is %.2fx faster (saved %.4f s).\n', speedup, time_diff);
        else
            fprintf('CPU version is %.2fx faster (saved %.4f s).\n', 1/speedup, abs(time_diff));
        end
    else
        fprintf('\nCould not calculate statistics due to errors.\n');
    end
end

function elapsedTime = run_safe(scriptName)
    % Reads the script, comments out 'clear' and 'close all',
    % writes to a temp file, runs it, and returns elapsed time.
    
    % 1. Read content
    fid = fopen(scriptName, 'r');
    if fid == -1
        error('Could not open file %s', scriptName);
    end
    raw_code = fscanf(fid, '%c');
    fclose(fid);
    
    % 2. Modify content (Regex to comment out clear/close all)
    % Matches "clear", "clear all", "close all" at start of line or after semicolon
    % We replace them with a comment.
    
    % Replace 'clear ...' with '% clear ...'
    % (?m) enables multiline mode. ^\s* matches start of line + whitespace.
    modified_code = regexprep(raw_code, '(?m)^(\s*)(clear|close\s+all)', '$1% $2');
    
    % Also handle cases like "clc; clear;" -> "clc; % clear;"
    % This is trickier with regex, but covering start-of-line is usually enough for main scripts.
    % Let's try a safer replace for standalone commands.
    modified_code = regexprep(modified_code, '(\s|;)(clear)(\s|;|$)', '$1% $2$3');
    modified_code = regexprep(modified_code, '(\s|;)(close\s+all)(\s|;|$)', '$1% $2$3');

    % 3. Write temp file
    tempScriptName = ['temp_bench_' scriptName];
    fid = fopen(tempScriptName, 'w');
    fprintf(fid, '%s', modified_code);
    fclose(fid);
    
    % 4. Run and Time
    try
        t_start = tic;
        run(tempScriptName);
        elapsedTime = toc(t_start);
        
        % Cleanup
        delete(tempScriptName);
    catch ME
        % Cleanup even on error
        if exist(tempScriptName, 'file')
            delete(tempScriptName);
        end
        rethrow(ME);
    end
end