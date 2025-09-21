function p_hat = decode_uSS(Y, params)
    % Decoder for uSS
    % Compute estimator from Y : n by w matrix
    % params : struct(eps, \mathcal{X}, \mathcal{X}_S)
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
    freq = sum(Y, 1) / n;
    k = max(max(sum(Y, 2)) - 1, 1);
    
    % Closed-form coefficients
    p_star = k * expEps / (k * expEps + v - k);
    q_star = k * (k * expEps + v - k - expEps) / (k * expEps + v - k) ...
        / (v - 1);
    z_star = k * (expEps - 1) / (k * (expEps - 1) + v);

    % Initialize output
    p_hat = zeros(w, 1);

    % Estimate for sensitive symbols
    p_hat(sensSet) = freq(sensSet) / (p_star - q_star) ...
        - q_star / (p_star - q_star);

    % Estimate for non-sensitive symbols
    p_hat(nonSet) = freq(nonSet) / z_star;
    
    % Ensure non-negative, normalize
    p_hat = max(p_hat, 0);
    p_hat = p_hat / sum(p_hat);
end