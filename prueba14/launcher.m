current_dir = pwd;
figures_dir = fullfile(current_dir, 'figures');
if ~exist(figures_dir, 'dir')
    mkdir(figures_dir);
end

L_param = 16; 
K = 15;
K_param = K;
S_param = (sqrt(L_param) + 1)^2;
N_RIS = 64;
indices = 1:12;
closest = 0;

% %% Case 1: All RISs assigned randomly to just one user
% fprintf('Running Case 1: All RISs assigned to 1 random user...\n');
% risAssignment = cell(S_param, 1);
% for aux = 1:S_param
%     risAssignment{aux} = randi(K_param);
% end
% tau_p = 0; 
% for s = 1:S_param
%     tau_p = tau_p + sum(1 * (1 + N_RIS));
% end
% tau_p = tau_p + K;
% main1;
% savefig(gcf, fullfile(figures_dir, 'Random_1_User.fig'));
% close(gcf);
% 
% %% Case 2: All RISs assigned randomly to two users
% fprintf('Running Case 2: All RISs assigned to 2 random users...\n');
% risAssignment = cell(S_param, 1);
% for aux = 1:S_param
%     risAssignment{aux} = randperm(K_param, 2);
% end
% tau_p = 0; 
% for s = 1:S_param
%     tau_p = tau_p + sum(2 * (1 + N_RIS));
% end
% tau_p = tau_p + K;
% main1;
% savefig(gcf, fullfile(figures_dir, 'Random_2_Users.fig'));
% close(gcf);
% 
% %% Case 3: All RISs assigned to all users
% fprintf('Running Case 3: All RISs assigned to all users...\n');
% risAssignment = cell(S_param, 1);
% for aux = 1:S_param
%     risAssignment{aux} = 1:K_param;
% end
% tau_p = 0; 
% for s = 1:S_param
%     tau_p = tau_p + sum(10 * (1 + N_RIS));
% end
% tau_p = tau_p + K
% main1;
% savefig(gcf, fullfile(figures_dir, 'All_Users.fig'));
% close(gcf);
% 
% %% Case 4: All RISs assigned to just the closer user
%  fprintf('Running Case 4: All RISs assigned to just the closer user...\n');
%  RISassignment_array = getRISAssignments_closest(indices);
%  closest = 1;
%  tau_p = 0; 
%  for s = 1:S_param
%      tau_p = tau_p + sum(1 * (1 + N_RIS));
%  end
%  tau_p = tau_p + K;
%  tau_p
% main1;
% savefig(gcf, fullfile(figures_dir, 'Closest_User.fig'));
% close(gcf);
% 
% %% Case 5: All RISs assigned to the two closest users
% fprintf('Running Case 5: All RISs assigned to the two closest users...\n');
% RISassignment_array = getRISAssignments_closest_two(indices);
% closest = 2;
% tau_p = 0; 
% for s = 1:S_param
%     tau_p = tau_p + sum(2 * (1 + N_RIS));
% end
% tau_p = tau_p + K;
% main1;
% savefig(gcf, fullfile(figures_dir, 'Two_Closest_User.fig'));
% close(gcf);
% 
% %% Case 6: All RISs assigned to closest and to 2nd closest if in 150m range
% fprintf('Running Case 6: All RISs assigned to closest and to 2nd closest if in 150m range...\n');
% RISassignment_array = getRISAssignments_threshold(indices, 150);
% tau_p_factor_array = zeros(size(indices));
% 
% for n = indices
%     totalusers = sum(cellfun(@numel, RISassignment_array(:, n)));
%     tau_p_factor_array(1, n) = totalusers/S_param;
% end
% 
% closest = 2;
% tau_p = 0; 
% for s = 1:S_param
%     tau_p = tau_p + sum(mean(tau_p_factor_array) * (1 + N_RIS));
% end
% tau_p = tau_p + K;
% tau_p = round(tau_p);
% main1;
% savefig(gcf, fullfile(figures_dir, 'Two_Closest_User_Threshold_150m.fig'));
% close(gcf);
% 
% %% Case 7: All RISs assigned to closest and to 2nd closest if in 300m range
% fprintf('Running Case 7: All RISs assigned to closest and to 2nd closest if in 300 range...\n');
% RISassignment_array = getRISAssignments_threshold(indices, 300);
% tau_p_factor_array = zeros(size(indices));
% 
% for n = indices
%     totalusers = sum(cellfun(@numel, RISassignment_array(:, n)));
%     tau_p_factor_array(1, n) = totalusers/S_param;
% end
% 
% closest = 2;
% tau_p = 0; 
% for s = 1:S_param
%     tau_p = tau_p + sum(mean(tau_p_factor_array) * (1 + N_RIS));
% end
% tau_p = tau_p + K;
% tau_p = round(tau_p);
% main1;
% savefig(gcf, fullfile(figures_dir, 'Two_Closest_User_Threshold_300m.fig'));
% close(gcf);

% %% Case 8: All RISs assigned to closest and to 2nd closest if in 180m range
% fprintf('Running Case 8: All RISs assigned to closest and to 2nd closest if in 180 range...\n');
% RISassignment_array = getRISAssignments_threshold(indices, 180);
% tau_p_factor_array = zeros(size(indices));
% 
% for n = indices
%     totalusers = sum(cellfun(@numel, RISassignment_array(:, n)));
%     tau_p_factor_array(1, n) = totalusers/S_param;
% end
% 
% closest = 2;
% tau_p = 0;
% for s = 1:S_param
%     tau_p = tau_p + sum(mean(tau_p_factor_array) * (1 + N_RIS));
% end
% tau_p = tau_p + K;
% tau_p = round(tau_p);
% main1;
% savefig(gcf, fullfile(figures_dir, 'Two_Closest_User_Threshold_180m.fig'));
% close(gcf);
% 
% fprintf('All simulations completed.\n');

%% Case 9: RISs assigned to closest if in a certain range (100m), if not, set to random config
fprintf('Running Case 9: RISs assigned to closest if in a certain range (100m), if not, set to random config...\n');
max_dist = 60;
[RISassignment_array, assigned_counts, unassigned_counts] = getRISAssignments_closest_unsassigned_RISs(indices, max_dist);
assigned_counts
RISassignment_array
closest = 3;
tau_p_array = zeros(size(indices));
for n = indices
    tau_p = 0; 
    for s = 1:assigned_counts(n)
     tau_p = tau_p + sum(1 * (1 + N_RIS));
    end
    tau_p = tau_p + K;
    tau_p_array(1,n) = tau_p; 
    tau_p
end
tau_p_array
main1;
savefig(gcf, fullfile(figures_dir, 'Closest_if_60m.fig'));
close(gcf);

% %% Case 10: RISs assigned to closest if in a certain range (200m), if not, set to random config
% fprintf('Running Case 10: RISs assigned to closest if in a certain range (200m), if not, set to random config...\n');
% max_dist = 200;
% [RISassignment_array, assigned_counts, unassigned_counts] = getRISAssignments_closest_unsassigned_RISs(indices, max_dist);
% assigned_counts
% RISassignment_array
% closest = 3;
% tau_p_array = zeros(size(indices));
% for n = indices
%     tau_p = 0; 
%     for s = 1:assigned_counts(n)
%      tau_p = tau_p + sum(1 * (1 + N_RIS));
%     end
%     tau_p = tau_p + K;
%     tau_p_array(1,n) = tau_p; 
%     tau_p
% end
% tau_p_array
% main1;
% savefig(gcf, fullfile(figures_dir, 'Closest_if_200m.fig'));
% close(gcf);

% %% Case 11: RISs assigned to closest if in a certain range (150m), if not, set to random config
% fprintf('Running Case 11: RISs assigned to closest if in a certain range (150m), if not, set to random config...\n');
% max_dist = 150;
% [RISassignment_array, assigned_counts, unassigned_counts] = getRISAssignments_closest_unsassigned_RISs(indices, max_dist);
% assigned_counts
% RISassignment_array
% closest = 3;
% tau_p_array = zeros(size(indices));
% for n = indices
%     tau_p = 0; 
%     for s = 1:assigned_counts(n)
%      tau_p = tau_p + sum(1 * (1 + N_RIS));
%     end
%     tau_p = tau_p + K;
%     tau_p_array(1,n) = tau_p; 
%     tau_p
% end
% tau_p_array
% main1;
% savefig(gcf, fullfile(figures_dir, 'Closest_if_150m.fig'));
% close(gcf);
% 
% %% Case 12: RISs assigned to closest if in a certain range (175m), if not, set to random config
% fprintf('Running Case 12: RISs assigned to closest if in a certain range (175m), if not, set to random config...\n');
% max_dist = 175;
% [RISassignment_array, assigned_counts, unassigned_counts] = getRISAssignments_closest_unsassigned_RISs(indices, max_dist);
% assigned_counts
% RISassignment_array
% closest = 3;
% tau_p_array = zeros(size(indices));
% for n = indices
%     tau_p = 0; 
%     for s = 1:assigned_counts(n)
%      tau_p = tau_p + sum(1 * (1 + N_RIS));
%     end
%     tau_p = tau_p + K;
%     tau_p_array(1,n) = tau_p; 
%     tau_p
% end
% tau_p_array
% main1;
% savefig(gcf, fullfile(figures_dir, 'Closest_if_175m.fig'));
% close(gcf);
% 
% %% Case 13: RISs assigned to closest if in a certain range (250m), if not, set to random config
% fprintf('Running Case 13: RISs assigned to closest if in a certain range (250m), if not, set to random config...\n');
% max_dist = 250;
% [RISassignment_array, assigned_counts, unassigned_counts] = getRISAssignments_closest_unsassigned_RISs(indices, max_dist);
% assigned_counts
% RISassignment_array
% closest = 3;
% tau_p_array = zeros(size(indices));
% for n = indices
%     tau_p = 0; 
%     for s = 1:assigned_counts(n)
%      tau_p = tau_p + sum(1 * (1 + N_RIS));
%     end
%     tau_p = tau_p + K;
%     tau_p_array(1,n) = tau_p; 
%     tau_p
% end
% tau_p_array
% main1;
% savefig(gcf, fullfile(figures_dir, 'Closest_if_250m.fig'));
% close(gcf);

% %% Case 14: RISs assigned to closest if in a certain range (360m), if not, set to random config
% fprintf('Running Case 14: RISs assigned to closest if in a certain range (360m), if not, set to random config...\n');
% max_dist = 360;
% [RISassignment_array, assigned_counts, unassigned_counts] = getRISAssignments_closest_unsassigned_RISs(indices, max_dist);
% assigned_counts
% RISassignment_array
% closest = 3;
% tau_p_array = zeros(size(indices));
% for n = indices
%     tau_p = 0; 
%     for s = 1:assigned_counts(n)
%      tau_p = tau_p + sum(1 * (1 + N_RIS));
%     end
%     tau_p = tau_p + K;
%     tau_p_array(1,n) = tau_p; 
%     tau_p
% end
% tau_p_array
% main1;
% savefig(gcf, fullfile(figures_dir, 'Closest_if_360m.fig'));
% close(gcf);

% %% Case 15: RISs assigned to closest if in a certain range (200m), and APs have their own radius just for them (31.125m)
% fprintf('Running Case 15: RISs assigned to closest if in a certain range (200m), and APs have their own radius just for them (31.125m)...\n');
% max_dist = 200;
% ap_dist = 31.125;
% [RISassignment_array, assigned_counts, unassigned_counts] = getRISAssignments_AP_zone_closest(indices, max_dist, ap_dist);
% assigned_counts
% RISassignment_array
% closest = 3;
% tau_p_array = zeros(size(indices));
% for n = indices
%     tau_p = 0; 
%     for s = 1:assigned_counts(n)
%      tau_p = tau_p + sum(1 * (1 + N_RIS));
%     end
%     tau_p = tau_p + K;
%     tau_p_array(1,n) = tau_p; 
%     tau_p
% end
% tau_p_array
% main1;
% savefig(gcf, fullfile(figures_dir, 'Closest_if_200m_AP_31m.fig'));
% close(gcf);

% %% Case 16: RISs assigned to closest if in a certain range (200m), and APs have their own radius just for them (100m)
% fprintf('Running Case 16: RISs assigned to closest if in a certain range (200m), and APs have their own radius just for them (100m)...\n');
% max_dist = 200;
% ap_dist = 100;
% [RISassignment_array, assigned_counts, unassigned_counts] = getRISAssignments_AP_zone_closest(indices, max_dist, ap_dist);
% assigned_counts
% RISassignment_array
% closest = 3;
% tau_p_array = zeros(size(indices));
% for n = indices
%     tau_p = 0; 
%     for s = 1:assigned_counts(n)
%      tau_p = tau_p + sum(1 * (1 + N_RIS));
%     end
%     tau_p = tau_p + K;
%     tau_p_array(1,n) = tau_p; 
%     tau_p
% end
% tau_p_array
% main1;
% savefig(gcf, fullfile(figures_dir, 'Closest_if_200m_AP_100m.fig'));
% close(gcf);

% %% Case 17: RISs assigned to closest if in a certain range (200m), and APs have their own radius just for them (45m)
% fprintf('Running Case 17: RISs assigned to closest if in a certain range (200m), and APs have their own radius just for them (45m)...\n');
% max_dist = 200;
% ap_dist = 45;
% [RISassignment_array, assigned_counts, unassigned_counts] = getRISAssignments_AP_zone_closest(indices, max_dist, ap_dist);
% assigned_counts
% RISassignment_array
% closest = 3;
% tau_p_array = zeros(size(indices));
% for n = indices
%     tau_p = 0; 
%     for s = 1:assigned_counts(n)
%      tau_p = tau_p + sum(1 * (1 + N_RIS));
%     end
%     tau_p = tau_p + K;
%     tau_p_array(1,n) = tau_p; 
%     tau_p
% end
% tau_p_array
% main1;
% savefig(gcf, fullfile(figures_dir, 'Closest_if_200m_AP_45m.fig'));
% close(gcf);

% %% Case 18: RISs assigned to closest if in a certain range (200m), and APs have their own radius just for them (25m)
% fprintf('Running Case 18: RISs assigned to closest if in a certain range (200m), and APs have their own radius just for them (25m)...\n');
% max_dist = 200;
% ap_dist = 25;
% [RISassignment_array, assigned_counts, unassigned_counts] = getRISAssignments_AP_zone_closest(indices, max_dist, ap_dist);
% assigned_counts
% RISassignment_array
% closest = 3;
% tau_p_array = zeros(size(indices));
% for n = indices
%     tau_p = 0; 
%     for s = 1:assigned_counts(n)
%      tau_p = tau_p + sum(1 * (1 + N_RIS));
%     end
%     tau_p = tau_p + K;
%     tau_p_array(1,n) = tau_p; 
%     tau_p
% end
% tau_p_array
% main1;
% savefig(gcf, fullfile(figures_dir, 'Closest_if_200m_AP_25m.fig'));
% close(gcf);

% %% Case 19: RISs assigned to closest if in a certain range (200m), and APs have their own radius just for them (15m)
% fprintf('Running Case 19: RISs assigned to closest if in a certain range (200m), and APs have their own radius just for them (15m)...\n');
% max_dist = 200;
% ap_dist = 15;
% [RISassignment_array, assigned_counts, unassigned_counts] = getRISAssignments_AP_zone_closest(indices, max_dist, ap_dist);
% assigned_counts
% RISassignment_array
% closest = 3;
% tau_p_array = zeros(size(indices));
% for n = indices
%     tau_p = 0; 
%     for s = 1:assigned_counts(n)
%      tau_p = tau_p + sum(1 * (1 + N_RIS));
%     end
%     tau_p = tau_p + K;
%     tau_p_array(1,n) = tau_p; 
%     tau_p
% end
% tau_p_array
% main1;
% savefig(gcf, fullfile(figures_dir, 'Closest_if_200m_AP_15m.fig'));
% close(gcf);

% %% Case 20: Case 15 with upgraded function
% fprintf('Running Case 20: Case 15 with upgraded function...\n');
% max_dist = 200;
% ap_dist = 31.125;
% [RISassignment_array, assigned_counts, unassigned_counts] = getRISAssignments_AP_zone_closest_upgraded(indices, max_dist, ap_dist);
% assigned_counts
% RISassignment_array
% closest = 3;
% tau_p_array = zeros(size(indices));
% for n = indices
%     tau_p = 0; 
%     for s = 1:assigned_counts(n)
%      tau_p = tau_p + sum(1 * (1 + N_RIS));
%     end
%     tau_p = tau_p + K;
%     tau_p_array(1,n) = tau_p; 
%     tau_p
% end
% tau_p_array
% main1;
% savefig(gcf, fullfile(figures_dir, 'Closest_if_200m_AP_31m_tauc10000_upg.fig'));
% close(gcf);

fprintf('All simulations completed.\n');