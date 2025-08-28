function p_hat = decode_uHR(Y, params)
    % Decoder for uHR
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
    V = 2^nextpow2(v + 1);
    delta = V - v;
    cnt = accumarray(Y, 1, [w + delta 1]);
    freq = cnt / n;

    % Closed-form coefficients
    coeff1 = (expEps + 1) / (expEps - 1);
    coeff2 = 2 / (expEps + 1);
    
    % Initialize output
    p_hat = zeros(w, 1);
    
    % Estimate for sensitive symbols
    H = hadamard(V);
    H = H(2 : v + 1, :);
    Hpos = (H == 1);
    p_hat_S = sum(freq(1 : V));
    p_hat_A = coeff1 * (p_hat_S - coeff2);
    p_hat_Si = Hpos * freq(1 : V);
    p_hat(sensSet) = 2 * coeff1 * (p_hat_Si - 1 / (expEps + 1))...
        - p_hat_A;

    % Estimate for nonsensitive symbols
    p_hat(nonSet) = coeff1 * freq(V + 1 : end);
    
    % Ensure non-negative, normalize
    p_hat = max(p_hat, 0);
    p_hat = p_hat / sum(p_hat);
end