
%% load data

function [data, label, inds_label, data_sp, sp_vec, sp_list, data_sp_cell, adj_sp] =...
    load_data_sp_func(data_type, num_class, fig_name, nC, flag_mask)

if strcmp(data_type, 'IP')
    load IP_200_M;
end
if strcmp(data_type, 'PC')
    load PC_102_M;
end
if strcmp(data_type, 'SV')
    load SV_204_M;
end
[rows, cols, n_bands] = size(data_M);

load(['Label_M_', data_type, '_', num2str(num_class), '.mat']);

label_All = label_M(:);
inds_label = find(label_All > 0);
label = label_All(inds_label);
label_inv_inds_vec = label_All <= 0;

data_All = double(reshape(data_M, [rows * cols, n_bands])) / 255;
sp_map = Superpixel_func(fig_name, nC);
label_superpixel_All = sp_map(:);
if min(label_superpixel_All) == 0
    label_superpixel_All = label_superpixel_All + 1;
end

if flag_mask
    data = data_All(inds_label, :);
    label_superpixel_All(label_inv_inds_vec) = 0;
    label_sp_vec = label_sp_vec_processing(label_superpixel_All);
    sp_vec = label_sp_vec(inds_label);
else
    data = data_All;
    label_sp_vec = label_superpixel_All;
    sp_vec = label_superpixel_All;
end

sp_list = unique(sp_vec);
num_sp = length(sp_list);

data_sp = zeros(num_sp, size(data, 2));
data_sp_cell = cell(num_sp, 1);
for ii_sp = 1:num_sp
    inds_temp = sp_vec == sp_list(ii_sp);
    data_temp = data(inds_temp, :);
    data_sp(ii_sp, :) = mean(data_temp, 1);
    data_sp_cell{ii_sp, 1} = data_temp;
end

%%
num_sp = max(label_sp_vec);
label_sp_M = reshape(label_sp_vec, [rows, cols]);

adj_sp_temp = zeros(num_sp);
for ii_sp = 1:num_sp-1
    [rr_1, cc_1] = find(label_sp_M == ii_sp);
    rc_1 = [rr_1, cc_1];
    for jj_sp = ii_sp+1:num_sp
        [rr_2, cc_2] = find(label_sp_M == jj_sp);
        rc_2 = [rr_2, cc_2];
        dist_temp = pdist2(rc_1, rc_2);
        if min(dist_temp(:)) == 1
            adj_sp_temp(ii_sp, jj_sp) = 1;
        end
    end
end

adj_sp = adj_sp_temp + adj_sp_temp';