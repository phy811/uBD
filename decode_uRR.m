function p_hat = decode_uRR(Y, params)
    % Decoder for uRR
    % Compute estimator from Y : n by 1
    % params : struct(eps, \mathcal{X}, \mathcal{X}_S)
    % p_hat : w by 1
    %======================================================================
    % Extract parameters
    epsilon = params.eps;       % privacy constraint
    expEps = exp(epsilon);
    domain = params.X;
    sensSet = params.XS;
    nonSet = setdiff(domain, sensSet);
    w = numel(domain);          % |\mathcal{X}|
    v = numel(sensSet);         % |\mathcal{X}_S|
    n = size(Y, 1);             % number of users

    % Compute empirical frequencies for each symbol
    cnt = accumarray(Y, 1, [w 1]);
    freq = cnt / n;
    
    % Closed-form coefficients
    pInclSens = expEps / (expEps + v - 1);
    pExclSens = (1 - pInclSens) / (v - 1);
    pInclNon = (expEps - 1)/(expEps + v - 1);
    
    % Initialize output
    p_hat = zeros(w, 1);
    
    % Estimate for sensitive symbols
    p_hat(sensSet) = (freq(sensSet) - pExclSens) / (pInclSens - pExclSens);

    % Estimate for nonsensitive symbols
    p_hat(nonSet) = freq(nonSet) / pInclNon;

    % Ensure non-negative, normalize
    p_hat = max(p_hat, 0);
    p_hat = p_hat / sum(p_hat);
end