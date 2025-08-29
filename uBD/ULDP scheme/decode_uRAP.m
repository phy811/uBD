function p_hat = decode_uRAP(Y, params)
    % Decoder for uRAP
    % Compute estimator from Y : n by w
    % params : struct(eps, \mathcal{X}, \mathcal{X}_S)
    % p_hat : w by 1
    %======================================================================
    % Extract parameters
    epsilon = params.eps;       % privacy constraint
    domain = params.X;
    sensSet = params.XS;
    nonSet = setdiff(domain, sensSet);
    w = numel(domain);          % |\mathcal{X}|
    n = size(Y, 1);             % number of users

    % Compute empirical frequencies for each symbol
    freq = sum(Y, 1) / n;

    % Closed-form coefficients
    pKeepSelfSens = exp(epsilon / 2) / (exp(epsilon / 2) + 1);
    pFlipSens = 1 / (exp(epsilon / 2) + 1);
    pKeepSelfNon = (exp(epsilon / 2) - 1) / exp(epsilon / 2);  

    % Initialize output
    p_hat = zeros(w,1);
    
    % Estimate for sensitive symbols
    p_hat(sensSet) = (freq(sensSet) - pFlipSens) /...
        (pKeepSelfSens - pFlipSens);

    % Estimate for nonsensitive symbols
    p_hat(nonSet) = freq(nonSet) / pKeepSelfNon;

    % Ensure non-negative, normalize
    p_hat = max(p_hat, 0);
    p_hat = p_hat / sum(p_hat);
end