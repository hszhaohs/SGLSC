function acc_kappa = metric_func(truth_label, predict_label)

% claculate OA, AA, Kappa coefficient
% Input£º truth_label
%         predict_label
% Output:
%         [OA, AA, KC]

cfmatrix = confusionmat(truth_label,predict_label);
OA = sum(diag(cfmatrix)) / length(truth_label);

n1 = sum(cfmatrix);    % num samples of each class (predicted)
n2 = sum(cfmatrix, 2);    % num samples of each class (ground truth)
N = sum(n1);    % total samples number
KC = ((N * sum(diag(cfmatrix))) - n1 * n2)/(N^2 - n1 * n2);

AA = mean(diag(cfmatrix) ./ n2);
acc_kappa = [OA, AA, KC];
end