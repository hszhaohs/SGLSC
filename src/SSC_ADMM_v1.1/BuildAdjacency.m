%--------------------------------------------------------------------------
% This function takes a NxN coefficient matrix and returns a NxN adjacency
% matrix by choosing the K strongest connections in the similarity graph
% CMat: NxN coefficient matrix
% K: number of strongest edges to keep; if K=0 use all the exiting edges
% CKSym: NxN symmetric adjacency matrix
%--------------------------------------------------------------------------
% Copyright @ Ehsan Elhamifar, 2012
%--------------------------------------------------------------------------

% function [CKSym, CAbs] = BuildAdjacency(CMat, K)
function CKSym = BuildAdjacency(CMat, K)

if (nargin < 2)
    K = 0;
end

N = size(CMat, 1);
CAbs = abs(CMat);

[Srt, Ind] = sort(CAbs, 1, 'descend');

if K == 0
    for ii = 1:N
        CAbs(:, ii) = CAbs(:, ii) ./ (CAbs(Ind(1, ii), ii) + eps);
    end
else
    for ii = 1:N
        for jj = 1:K
            CAbs(Ind(jj, ii), ii) = CAbs(Ind(jj, ii), ii) ./ (CAbs(Ind(1, ii), ii) + eps);
        end
    end
end

CKSym = CAbs + CAbs';
