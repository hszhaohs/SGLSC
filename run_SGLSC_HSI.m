%% main code of superpixel sparse subspace cluster for unsupervised HSI classification.

clear; clc;
rootpath = pwd;
addpath(genpath(fullfile(rootpath, 'data')));
addpath(genpath(fullfile(rootpath, 'src')));
%% Set result path
header_avg = {'n_SP', 'lambda', 'alpha', 'OA_avg', 'AA_avg', 'KC_avg',...
    'TimeAll_avg', 'TimeData_avg', 'OA_std', 'AA_std', 'KC_std', 'TimeAll_std', 'TimeData_std'};

flag_mask = 0;    % mask the data with only labeled pixel for performimg clustering  - 1 or 0 (mask or no)
data_type = 'PC';    % 'IP' 'SV' 'PC'
switch data_type
    case 'IP'
        num_class = 16;    % number of classes 9 16
        Num_SP = 1500; %1000:250:2000;    % number of superpixel
        Lambda = 15; %5:5:50;
        Alpha = 0.7; %0:0.1:1;
        rbf_sigma = 1;
        r = 60;
        rho = 0.1;
        outlier = 1;
        affine = 0;
        Seeds = 1011;
    case 'SV'
        num_class = 16;    % number of classes
        Num_SP = 500; %500:250:1500;    % number of superpixel
        Lambda = 1000; %500:100:1500;
        Alpha = 0.5; %0:0.1:1;
        rbf_sigma = 1;
        r = 40;
        rho = 0.3;
        outlier = 1;
        affine = 0;
        Seeds = 1011;
    case 'PC'
        num_class = 9;    % number of classes
        Num_SP = 1750; %1000:250:2000;    % number of superpixel
        Lambda = 40; %10:10:80;
        Alpha = 0.9; %0:0.1:1;
        rbf_sigma = 1;
        r = 20;
        rho = 0.7;
        outlier = 1;
        affine = 0;
        Seeds = 1011;
end
data_name = [data_type, '_', num2str(num_class)];
fig_name = [data_type, '_PCA.tif'];

%% main
result_path_all = fullfile(rootpath, 'result_All_SGLSC');
mkdir(result_path_all);
result_all = [];
dirname_data = ['result_', data_name, '_FlagMask-', num2str(flag_mask)];
result_path = fullfile(result_path_all, dirname_data);
mkdir(result_path);
for ii_sp = 1:length(Num_SP)
    num_SP = Num_SP(ii_sp);
    dirname_SP = [data_name, '_SP-', num2str(num_SP)];
    path_SP = fullfile(result_path, dirname_SP);
    mkdir(path_SP);
    %% load data
    time_data_start = clock;
    
    % load HSI dataset & execute superpixel segmentation & intergrate
    [data, label, inds_label, data_sp, sp_vec, sp_list, data_sp_cell, adj_sp] =...
        load_data_sp_func(data_type, num_class, fig_name, num_SP, flag_mask);
    X = data_sp';
    
    time_data_end = clock;
    time_data = etime(time_data_end, time_data_start);
    
    num_loops = size(Lambda, 1);
    time_eta_start = datetime('now','Format','HH:mm:ss.SS');
    
    %% RBF Graph
    time_graph_start = clock;
    % local similarity graph
    spatial_graph = spatial_graph_creating(data_sp, adj_sp, rbf_sigma);
    % normalize spatial_graph
    spatial_graph = spatial_graph ./ repmat(max(spatial_graph), size(spatial_graph, 1), 1);
    time_graph_end = clock;
    time_graph = etime(time_graph_end, time_graph_start);
    %% SSC
    % coefficient of sparse self-representation (superpixel level)
    result_ssc = [];
    num_Lambda = size(Lambda, 1);
    for ii_lambda = 1:num_Lambda
        time_eta_end = datetime('now','Format','HH:mm:ss.SS');
        time_eta_iter = (time_eta_end - time_eta_start) / max(ii_lambda - 1, 1);
        time_eta = time_eta_iter * (num_loops - ii_lambda + 1);
        fprintf('doing %s: FlagMask=%d -> ParamLambda of %03d/%03d -> eta of NumSP=%04d: %s ...\n',...
            data_name, flag_mask, ii_lambda, num_Lambda, num_SP, time_eta);        
        lambda = Lambda(ii_lambda, :);
        time_ssc_start = clock;
        % global similarity graph
        ssc_coef = SSC_HSI(X, r, affine, lambda, outlier, rho);
        time_ssc_end = clock;
        time_ssc = etime(time_ssc_end, time_ssc_start);
        
        %% merge coefficient of sparse representation and RBF Graph
        result_alpha = [];
        for ii_alpha = 1:length(Alpha)
            alpha = Alpha(ii_alpha);
            coef = alpha * ssc_coef/2 + (1 - alpha) * spatial_graph;
            
            %% spectral clustering
            result_seed = [];
            for ii_seed = 1:length(Seeds)
                seed = Seeds(ii_seed);
                rng('default');
                rng(seed);
                time_sc_start = clock;
                grps = SpectralClustering(coef, num_class);
                
                time_sc_end = clock;
                time_sc = etime(time_sc_end, time_sc_start);
                time_cost = time_data + time_graph + time_ssc + time_sc;
                
                label_predict0 = zeros(size(sp_vec));
                for ii_class = 1:num_class
                    inds = find(grps == ii_class);
                    for jj = 1:length(inds)
                        label_predict0(sp_vec == sp_list(inds(jj))) = ii_class;
                    end
                end
                
                if flag_mask
                    label_predict = label_predict0;
                else
                    label_predict = label_predict0(inds_label);
                end
                
                label_predict_new = bestMap(label, label_predict);
                acc_kappa = metric_func(label, label_predict_new);
                result_temp = [seed, num_SP, lambda, alpha, acc_kappa, time_cost, time_data];
                result_seed = [result_seed; result_temp];
            end
            result_avg_temp = mean(result_seed(:, 2:end), 1);
            result_std_temp = std(result_seed(:, end-4:end), 1, 1);
            result_alpha = [result_alpha; [result_avg_temp, result_std_temp]];
        end
        result_ssc = [result_ssc; result_alpha];
    end
    result_all = [result_all; result_ssc];
    writetable(cell2table(num2cell(result_ssc), 'VariableNames', header_avg),...
        fullfile(path_SP, ['Avg_', dirname_SP, '.csv']));
end
writetable(cell2table(num2cell(result_all), 'VariableNames', header_avg),...
    fullfile(result_path, ['Avg_', dirname_data, '.csv']));


