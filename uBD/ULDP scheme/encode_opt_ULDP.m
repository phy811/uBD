function Y = encode_opt_ULDP(rawData, params)
    % Proposed encoder for each user data
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
    v = numel(sensSet);         % |\mathcal{X}_S|
    n = numel(rawData);         % number of users
    % opt_alpha = params.alpha;
    opt_t = params.t;
    
    % Pre-allocate output Y
    Y = false(n, w);

    % Classifiy users by sensitivity
    isSens = ismember(rawData, sensSet); 
    idxSens = find(isSens); 
    numSens = numel(idxSens);
    idxNon = find(~isSens); 
    
    randFlag = rand(n, 1);       % Uniform randoms for each user
    randFlagSens = randFlag(idxSens);
    randFlagNon = randFlag(idxNon);
    
    % Determine if mixture mode is active
    epsL = sqrt((v - 1) * (v - 2) / 2);
    epsH = w - v + sqrt((w - 1) * (w - 2) / 2);
    mix = false;
    if (epsL < expEps) && (expEps < epsH)
        % [~, opt_t, ~] = optimize_M(w, v, epsilon);
        mix = (nnz(opt_t) >= 2);
    end
    
    % Single-mode encoding (uniform k)
    if ~mix
        k = find(opt_t);
        % k = UnifParams(v, expEps);      % Optimal k
        % Encode sensitive data
        Y(idxSens, :) = encodeSensUsers(...
            rawData, params, idxSens, k, randFlagSens);
        
        % Encode nonsensitive data
        pInclNon = (expEps-1)/(expEps+v/k-1);
        xNon = rawData(idxNon);
        inclNon = (randFlag(idxNon) < pInclNon);    
        
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
    
    % Mixture-mode encoding
    else
        Y_P = false(numSens, w);
        % Compute cumulative weights for selection
        cdf_t = cumsum(opt_t);
        
        % Assign k for users with sensitive data
        k_Sens = discretize(randFlagSens, [0; cdf_t]);
        k = unique(k_Sens(k_Sens>0)).';

        % Encode sensitive data with chosen k
        for kk = k
            rel = (k_Sens == kk);

            Y_P(rel, :) = encodeSensUsers(...
                rawData, params, idxSens(rel),...
                kk, randFlagSens(rel));

        end
        Y(idxSens, :) = Y_P;
        
        % Encode nonsensitive data
        % Compute cumulative weights for selection
        pNon2Y_P = opt_t(k(:)) .* (v ./ (k(:) * expEps + v - k(:)));
        pInclNon = 1 - sum(pNon2Y_P);
        probVec = [pNon2Y_P ; pInclNon];
        cdfVec = cumsum(probVec);
        choice = discretize(randFlagNon, [0; cdfVec]);

        % Report \mathcal{Y}_I
        idMask = (choice == numel(probVec));
        idxInclNon = idxNon(idMask);
        Y(sub2ind([n, w], idxInclNon, rawData(idxInclNon))) = true;

        % Report \mathcal{Y}_P
        for kk = k
            rel = (choice == kk);
            absIdx = idxNon(rel);
            numNon2Y_P_k = numel(absIdx);
            randFlag_k = rand(numNon2Y_P_k, v);
            [~, cols] = mink(randFlag_k, kk, 2);
            Y(sub2ind([n,w], repmat(absIdx, 1, kk),...
                reshape(sensSet(cols), numNon2Y_P_k, kk))) = true;
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