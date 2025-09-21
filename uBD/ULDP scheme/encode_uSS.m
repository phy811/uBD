function Y = encode_uSS(rawData, params)
    % Encoder for uSS
    % rawData : n by 1
    % params : struct(eps, X, Xs)
    % Y : n by w
    %======================================================================
    % Extract parameter
    epsilon = params.eps;       % privacy constraint
    expEps = exp(epsilon);
    domain = params.X;
    sensSet = params.XS;
    w = numel(domain);          % |\mathcal{X}|
    v = numel(sensSet);         % |\mathcal{X}_S|
    n = numel(rawData);         % number of users 
    
    % Pre-allocate output Y
    Y = false(n, w);

    % Classifiy users by sensitivity
    isSens = ismember(rawData, sensSet); 
    idxSens = find(isSens); 
    idxNon = find(~isSens); 
    
    randFlag = rand(n, 1);       % Uniform randoms for each user
    randFlagSens = randFlag(idxSens);
    
    % Find optimal k for uSS
    k = find_opt_k(v, expEps);
    % Encode sensitive data
    Y(idxSens, :) = encodeSensUsers(...
        rawData, params, idxSens, k, randFlagSens);
        
    % Encode nonsensitive data
    f = v * (expEps * (k - 1) - k + v) / (v - 1) / (k * (expEps - 1) + v);
    xNon = rawData(idxNon);
    inclNon = (randFlag(idxNon) >= f);    
        
    % Report \mathcal{Y}_I
    idxInclNon = idxNon(inclNon);
    Y(sub2ind([n, w], idxInclNon, xNon(inclNon))) = true;
    
    % Report \mathcal{Y}_P
    idxExclNon = idxNon(~inclNon);
    numExclNon = numel(idxExclNon);
    randMatNon = rand(numExclNon, v);
    [~, colsNon] = mink(randMatNon, k, 2);
    subsetNon = reshape(sensSet(colsNon), numel(idxExclNon), k );
    Y(sub2ind([n, w], repmat(idxExclNon, 1, k), subsetNon)) = true;

    % Report tuple
    z = (expEps - 1) * (k - 1) / (expEps * (k - 1) - k + v);
    pairMask = (randFlag(idxExclNon) <= f*z);
    xNonExcl = xNon(~inclNon);     
    Y(sub2ind([n, w], idxExclNon(pairMask), xNonExcl(pairMask))) = true;
end

%==========================================================================
function opt_k = find_opt_k(v, expEps)
    % Find optimal k 
    % that minimize worst-case MSE of uSS
    %======================================================================
    best = inf;
    for k = 1 : v - 1
        A =  v * ((k*expEps - expEps + v - k) * (k * expEps - k + v - 1)) ... 
            / k / (v - k) / (expEps - 1)^2;
        B = (k * (1 - k) * (expEps - 1) + (v - 1) * (v - 2 * k) ) ...
            / (k * (v - k) * (expEps - 1));
        C = v / k / (expEps - 1);
        W = A + max(B, C);
        if W < best
            best = W; 
            opt_k = k;
        end
    end
end

%==========================================================================
function Y = encodeSensUsers(rawData, params,...
            idxSens, k, randFlagSens)
    % Encode sensitive data with given k
    %======================================================================
    % Extract parameters
    epsilon = params.eps;       % privacy constraint
    expEps = exp(epsilon);
    domain = params.X;
    sensSet = params.XS;
    w = numel(domain);          % |\mathcal{X}|
    v = numel(sensSet);         % |\mathcal{X}_S|
    numSens = numel(idxSens);

    % Position of each user value in \mathcal{X}_S
    [~, posSens] = ismember(rawData(idxSens), sensSet);
    
    % Inclusion probability for true value
    pInclSens =  expEps / (expEps + v/k - 1);
    inclSens = (randFlagSens < pInclSens);

    % Construct random matrix for block design
    randMatSens = rand(numSens, v); 

    % Exclude true value if not included
    linIdxSens = sub2ind([numSens, v], (1:numSens).', posSens);
    randMatSens(linIdxSens) = Inf;                        
    randMatSens(linIdxSens(inclSens)) = -Inf;           
    
    % Pick k smallest entries -> columns ofr each user
    [~, colsSens] = mink(randMatSens, k, 2);         
    subsetSens = reshape(sensSet(colsSens), numSens, k);             
    
    % Output Y \in \mathcal{Y}_P
    Y = false(numSens, w);
    Y(sub2ind([numSens, w], repmat((1:numSens).', 1, k),...
        subsetSens))= true; 
end