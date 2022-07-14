%% 处理超像素结果中的空格标签

function new_label_sp_vec = label_sp_vec_processing(label_sp_vec)

new_label_sp_vec = zeros(size(label_sp_vec));
sp_list = unique(label_sp_vec);

for ii = 1:length(sp_list)
    new_label_sp_vec(label_sp_vec == sp_list(ii)) = ii - 1;
end