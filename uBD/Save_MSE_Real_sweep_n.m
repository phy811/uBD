function Save_MSE_Real_sweep_n(combtype, m, eps)
    here = fileparts(mfilename('fullpath'));
    addpath(genpath(here));

    % Load data
    dataFile = sprintf('Data_%s.mat', lower(combtype));
    S        = load(dataFile,'ATTR','sensSet','domain');
    rawData  = S.ATTR;
    sensSet  = S.sensSet;
    domain   = S.domain;
    
    params.X  = domain;
    params.XS = sensSet;
    
    w = numel(domain);   v = numel(sensSet);
    nTotal = numel(rawData);
    pTrue  = accumarray(rawData,1,[w,1])/nTotal;    
    
    RList = 1e4:1e4:1e5;
    nR = numel(RList);
    
    rng(1, 'twister');
    maxR = max(RList);
    permIdx = zeros(m, maxR);
    
    for r = 1:m
        permIdx(r, :) = randperm(nTotal, maxR);
    end

    mse_uRR    = zeros(nR, m);
    mse_uRAP   = zeros(nR, m);
    mse_uOUE   = zeros(nR, m);
    mse_uHR    = zeros(nR, m);
    mse_uSS    = zeros(nR, m);
    mse_opt    = zeros(nR, m);
    mse_noPriv = zeros(nR, m);

    params.eps = eps;
    [opt_alpha, opt_t, ~] = optimize_M(w, v, params.eps);
    params.alpha = opt_alpha;
    params.t     = opt_t;
    params.k     = find_opt_k_uSS(v, exp(params.eps));

    for iR = 1:nR
        Rcur = RList(iR);
        for r = 1:m
            sub = rawData(permIdx(r,1:Rcur));

            mse_uRR(iR,r)  = computeMSE(@encode_uRR,  @decode_uRR,  sub, params, pTrue);
            mse_uRAP(iR,r) = computeMSE(@encode_uRAP, @decode_uRAP, sub, params, pTrue);
            mse_uOUE(iR,r) = computeMSE(@encode_uOUE, @decode_uOUE, sub, params, pTrue);
            mse_uHR(iR,r)  = computeMSE(@encode_uHR,  @decode_uHR,  sub, params, pTrue);
            mse_uSS(iR,r)  = computeMSE(@encode_uSS,  @decode_uSS,  sub, params, pTrue);
            mse_opt(iR,r)  = computeMSE(@encode_opt_ULDP, @decode_opt_ULDP, sub, params, pTrue);
        end
        fprintf('[%s] eps=%.4f | R %d/%d (%d) done\n', ...
            combtype, eps, iR, nR, Rcur);
    end
    outfile = sprintf('MSE_vsN_%s_eps%.3g_m%d.mat', lower(combtype), eps, m);
    save(outfile, ...
        'eps', 'RList', 'm', ...
        'mse_uRR','mse_uRAP','mse_uOUE','mse_uHR','mse_uSS','mse_opt', ...
        '-v7.3');
end