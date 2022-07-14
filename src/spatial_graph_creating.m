
function spatial_graph = spatial_graph_creating(data_sp, adj_sp, rbf_sigma)

% graph construction
num_samples = size(data_sp, 1);
spatial_graph = zeros(num_samples);

order_adj = max(adj_sp(:));
for ii = 1:num_samples
    for ii_order = 1:order_adj
        inds_adj = adj_sp(ii, :) == ii_order;
        data_adj = data_sp(inds_adj, :);
        diff = pdist2(data_adj, data_sp(ii, :));
        square_dist = diff.^2;
        rbf_sigma = mean(diff);
        spatial_graph(ii, inds_adj) = exp(square_dist / (-2 * rbf_sigma^2));
        spatial_graph(ii, inds_adj) = exp(square_dist / (-2 * rbf_sigma^2));
    end
end

end
