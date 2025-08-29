function Y = encode_uHR(rawData, params)
    % Encoder for uHR
    % rawData : n by 1
    % params : struct(eps, X, Xs)
    % Y : n by 1
    %======================================================================
    % Extract parameters
    epsilon = params.eps;       % privacy constraint
    expEps = exp(epsilon);
    sensSet = params.XS;
    v = numel(sensSet);         % |\mathcal{X}_S|
    n = numel(rawData);         % number of users
    
    % Pre-allocate output Y
    Y = zeros(n, 1);

    % Classify users by sensitivity
    [isSens, xiSens] = ismember(rawData, sensSet);
    isNon = ~isSens;      
    
    randFlag = rand(n, 1);       % Uniform randoms for each user

    % Generate Hadamard matrix and exclude first row
    V = 2^nextpow2(v + 1);
    H = hadamard(V);
    H = H(2 : v + 1, :);             % v by V
    delta = V - v;
    
    % Divide into +1/-1
    plusSet = cell(1, v);
    minusSet = cell(1, v);
    for i = 1 : v
        row = H(i, :);                       
        plusSet{i} = find(row ==  1);
        minusSet{i} = find(row == - 1);
    end

    % Encode sensitive data 
    pPlusSens = expEps / (expEps + 1);
    isPlus = (randFlag < pPlusSens);
    for r = 1 : v
        % Report +1 in H
        maskPlus = (xiSens == r & isPlus);
        choices = plusSet{r};
        numPlus = nnz(maskPlus);
        Y(maskPlus) = choices(randi(numel(choices), numPlus, 1));
        
        % Report -1 in H
        maskMinus = (xiSens == r & ~isPlus);
        choices = minusSet{r};
        numMinus = nnz(maskMinus);
        Y(maskMinus) = choices(randi(numel(choices), numMinus, 1));
    end
    
    % Encode nonsensitive data
    % Report \mathcal{Y}_I
    pInclNon = (expEps - 1) / (expEps + 1);
    inclNon = (isNon & (randFlag < pInclNon));
    Y(inclNon) = rawData(inclNon) + delta;

    % Report \mathcal{Y}_P
    non2Y_P = (isNon & ~inclNon);
    numNon2Y_P = nnz(non2Y_P);
    Y(non2Y_P) = randi(V, numNon2Y_P, 1);
end