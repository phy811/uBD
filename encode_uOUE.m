function Y = encode_uOUE(rawData, params)
    % Encoder for uOUE
    % rawData : n by 1
    % params : struct(eps, X, Xs)
    % Y : n by w matrix
    %======================================================================
    % Extract parameters
    epsilon = params.eps;       % privacy constraint
    expEps = exp(epsilon);
    domain = params.X;
    sensSet = params.XS;
    w = numel(domain);          % |\mathcal{X}|
    n = numel(rawData);         % number of users
    
    % Classify user by sensitivity
    isSens = ismember(rawData, sensSet);
    isNon = ~isSens;

    % Random flags for n users and each bit
    randFlag = rand(n, w);      

    % Decision for sensitive component
    pFlipSens = 1 / (expEps + 1);
    thresholds = zeros(1, w);
    thresholds(ismember(domain, sensSet)) = pFlipSens;
    Y = (randFlag < thresholds);

    % Decision for self
    pKeepSelfSens = 1 / 2;
    pKeepSelfNon = (expEps - 1) / 2 / expEps;
    keepProb = pKeepSelfSens * isSens + pKeepSelfNon * isNon;
    linIdx = sub2ind([n,w], (1 : n).', rawData);
    Y(linIdx) = (randFlag(linIdx) < keepProb);
end