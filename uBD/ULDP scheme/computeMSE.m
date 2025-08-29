function mse = computeMSE(encFun, decFun, rawData, params, pTrue)
    % Compute MSE
    % encFun : uRR, uRAP, uOUE, uHR, proposed
    % decFun : corresponding decoder
    % rawData : n by 1
    % params : struct(eps, X, Xs)
    % pTrue : true distribution
    %======================================================================
    Y = encFun(rawData, params);
    p_hat = decFun(Y, params);
    mse = mean((p_hat - pTrue) .^ 2 );
end