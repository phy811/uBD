function Y = encode_uRR(rawData, params)
    % Encoder for uRR
    % rawData : n by 1
    % params : struct(eps, X, Xs)
    % Y : n by 1
    %======================================================================
    % Extract parameter
    epsilon = params.eps;       % privacy constraint
    expEps = exp(epsilon);
    sensSet = params.XS;
    v = numel(sensSet);         % |\mathcal{X}_S|
    n = numel(rawData);         % number of users           

    % Pre-allocate output Y 
    Y = zeros(n, 1);
    
    % Classify user by sensitivity
    isSens = ismember(rawData, sensSet);
    isNon = ~isSens;
    
    % Random flags for n users
    randFlag = rand(n, 1);       
    
    % Encode sensitive data
    % Report true value
    pInclSens = expEps / (expEps + v - 1);
    inclSens = (isSens & (randFlag < pInclSens));
    Y(inclSens) = rawData(inclSens);
    
    % Report false value
    exclSens = (isSens & ~inclSens);
    [~, posSens] = ismember(rawData(exclSens), sensSet);
    r = randi(v - 1,numel(posSens), 1);
    selIdx = r + (r >= posSens);        % Exclude original value
    Y(exclSens) = sensSet(selIdx);

    % Encode nonsensitive data
    % Report \mathcal{Y}_I
    pInclNon = (expEps - 1) / (expEps + v - 1);
    inclNon = (isNon & (randFlag < pInclNon));
    Y(inclNon) = rawData(inclNon);
    
    % Report \mathcal{Y}_P
    non2Y_P = (isNon & ~inclNon);
    numNon2Y_P = nnz(non2Y_P);
    Y(non2Y_P) = sensSet(randi(v, numNon2Y_P, 1));
end