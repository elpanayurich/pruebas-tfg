file_indices = 1:1;
max_dist = 200;
ap_dist = 1;

[RISassignment_array, assigned_counts, unassigned_counts] = getRISAssignments_AP_zone_closest(file_indices, max_dist, ap_dist);