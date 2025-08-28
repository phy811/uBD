function p_hat = decode_opt_ULDP(Y, params)
    % Decoder for proposed mechanism
    % Compute estimator from Y : n by w matrix
    % params : struct(eps, \mathcal{X}, \mathcal{X}_S)
    % p_hat : w by 1
    %======================================================================
    % Extract parameters
    % epsilon = params.eps;       % privacy constraint
    % w = numel(params.X);        % |\mathcal{X}|
    % v = numel(params.XS);       % |\mathcal{X}_S|
    opt_alpha = params.alpha;
    opt_t = params.t;
    % Optimize mixture weights and identify active uniformity parameters
    % [opt_alpha, opt_t, ~] = optimize_M(w, v, epsilon);
    k = find(opt_t > 0).';

    if isscalar(k)
        p_hat = decode_single(Y, k, params);
    else
        p_hat = decode_mixture(Y, opt_alpha, opt_t, k, params);
    end
    
    % Ensure non-negative, normalize
    p_hat = max(p_hat, 0);
    p_hat = p_hat / sum(p_hat);
end

%==========================================================================
function p_hat = decode_single(Y, k, params)
    % Single mode estimator
    % Y : n by w
    % k : uniformity parameter (scalar)
    % params : struct(eps, X, Xs)
    % p_hat : w by 1
    %======================================================================
    % Extract parameters
    expEps = exp(params.eps);
    domain = params.X;
    sensSet = params.XS;
    nonSet = setdiff(domain, sensSet);
    w = numel(params.X);        % |\mathcal{X}|
    v = numel(params.XS);       % |\mathcal{X}_S|
    n = size(Y, 1);             % number of users

    % Compute empirical frequencies for each symbol
    freq = sum(Y, 1) / n;      % 1 by w

    % Closed-form coefficients
    coeff1 = (expEps - 1) / (expEps + v / k - 1);
    coeff2 = coeff1 * (v - k) / (v - 1);
    coeff3 = ((k - 1) * expEps + v - k) / ((v - k) * (expEps - 1));

    % Initialize output
    p_hat = zeros(w, 1);

    % Estimate for sensitive symbols
    p_hat(sensSet) = (freq(sensSet) + (k - 1) * sum(freq(nonSet)) / ...
        (v - 1)) / coeff2 - coeff3;

    % Estimate for non-sensitive symbols
    p_hat(nonSet) = freq(nonSet) / coeff1;
end

%==========================================================================
function p_hat = decode_mixture(Y, opt_alpha, opt_t, k, params)
    % Mixed mode estimator
    % Y : n by w
    % k : valid uniformity parameter (vector)
    % params : struct(eps, X, Xs)
    % p_hat : w by 1
    %======================================================================
    % Extract parameters
    eps = params.eps;           % privacy constraint
    expEps = exp(eps);
    domain = params.X;
    sensSet = params.XS;
    nonSet = setdiff(domain, sensSet);
    w = numel(domain);          % |\mathcal{X}|
    v = numel(sensSet);         % |\mathcal{X}_S|
    n = size(Y, 1);             % number of users

    % Base distribution
    P_alpha = zeros(w, 1);
    P_alpha(sensSet) = opt_alpha / v;
    P_alpha(nonSet) = (1 - opt_alpha) / (w - v);

    % Compute information coefficients $\overline{J}_1, \overline{J}_2,
    % \overline{J}_3$
    [~, J1, J2, J3] = compute_M_J(opt_alpha, opt_t, w, v, eps);
    
    [~, sensIdxGlobal] = ismember(domain, sensSet);

    % Split Y into sensitive part (first v columns) and nonsensitive part
    Y_P = Y(:, 1 : v);
    Y_I = Y(:, v+1 : end);

    % Initialize score function
    eta = zeros(w, 1);

    subsetSizes = sum(Y_P, 2);
    isMixtureRow = ismember(subsetSizes, k);
    idx = find(isMixtureRow);
    % Accumulate contributions from \mathcal{Y}_P
    for i = idx'
        subsetLocal = (Y_P(i, :));
        subsetGlobal = sensIdxGlobal(subsetLocal);
        Q_x = ones(w, 1);
        Q_x(subsetGlobal) = expEps;
        Q_y = sum(P_alpha .* Q_x);
        eta = eta + Q_x / Q_y / n;
    end

    % Accumulate contributions from \mathcal{Y}_I
    I = eye(w-v);

    % Match each Y to the \mathcal{Y}_I and compute frequencies
    [~, loc] = ismember(Y_I, I', 'rows');
    valid = (loc > 0);
    freq = accumarray(loc(valid), 1, [size(I, 2), 1]) / n;

    % Update eta
    eta = eta + [zeros(v, w-v) ; eye(w - v) * (w - v) / (1 - opt_alpha)]...
        * freq;

    % Projection to subspaces 
    [Phi1, Phi2, Phi3] = project2H(eta, v);

    % Final estimator
    p_hat = P_alpha + (Phi1 / J1 + Phi2 / J2 + Phi3 / J3);
end

%==========================================================================
function [proj1, proj2, proj3] = project2H(hvec, v)
    % Project a vector h onto \mathcal{H}_1, \mathcal{H}_2, \mathcal{H}_3
    %======================================================================
    w = numel(hvec);

    % \mathcal{H}_1 : zero-sum sensitive components
    m1 = mean(hvec(1 : v));
    proj1 = [hvec(1 : v) - m1 ; zeros(w - v,1)];
    
    % \mathcal{H}_2 : zero-sum nonsensitive components
    m2 = mean(hvec(v + 1 : w));
    proj2 = [zeros(v, 1) ; hvec(v + 1 : w) - m2];

    % \mathcal{H}_3 : span([(w-v)*1_v; -v*1_{w-v}])
    u = [(w - v) * ones(v, 1) ; - v *ones(w - v, 1)];
    proj3 = (u' * hvec) / (u' * u) * u;
end