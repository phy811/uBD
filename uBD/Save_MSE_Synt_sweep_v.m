function Save_MSE_Synt_sweep_v(w, n, m, R, eps, Type)
    here = fileparts(mfilename('fullpath'));
    addpath(genpath(here));
    
    datafile = sprintf('Synt_w=%d_n=%d_%s.mat', w, n, Type);
    S = load(datafile); % expects pTrue, Data
    pTrue   = S.pTrue(:);
    Data = S.Data(:);
    rng(1, "twister");
    subsampIdx = zeros(m, R);   % m×R
    for r = 1:m
        subsampIdx(r, :) = randperm(n, R);
    end
    params = struct();
    params.X  = 1:w;

    % Sweep v
    vList = 2:w;
    nV = numel(vList);

    mse_uRR  = zeros(nV, m);
    mse_uRAP = zeros(nV, m);
    mse_uOUE = zeros(nV, m);
    mse_uHR  = zeros(nV, m);
    mse_uSS  = zeros(nV, m);
    mse_opt  = zeros(nV, m);
    mse_noPriv = zeros(1, m);

    for r = 1:m
        sub = Data(subsampIdx(r,:));
        pHat_np = accumarray(sub,1,[w 1])/R;
        mse_noPriv(r) = sum((pHat_np-pTrue).^2);
    end
    
    for i = 1:nV
        v = vList(i);

        lp = params;
        lp.eps = eps;
        lp.XS  = 1:v;   % no subsampling, deterministic sensitive set

        [opt_alpha, opt_t, ~] = optimize_M(w, v, lp.eps);
        lp.alpha = opt_alpha;
        lp.t = opt_t;
        
        lp.k = find_opt_k_uSS(v, exp(eps));

        for r = 1:m
            sub = Data(subsampIdx(r,:));
            mse_uRR(i, r)  = computeMSE(@encode_uRR, @decode_uRR, ...
                sub, lp, pTrue);
            mse_uRAP(i, r) = computeMSE(@encode_uRAP, @decode_uRAP, ...
                sub, lp, pTrue);
            mse_uOUE(i, r) = computeMSE(@encode_uOUE, @decode_uOUE, ...
                sub, lp, pTrue);
            mse_uHR(i, r)  = computeMSE(@encode_uHR, @decode_uHR, ...
                sub, lp, pTrue);
            mse_uSS(i, r)  = computeMSE(@encode_uSS, @decode_uSS, ...
                sub, lp, pTrue);
            mse_opt(i, r)  = computeMSE(@encode_opt_ULDP, @decode_opt_ULDP, ...
                sub, lp, pTrue);
        end
        fprintf('[%s] v=%d/%d done (eps=%.4f)\n', Type, v, w, eps);
    end

    outfile = fullfile(here, sprintf( ...
        'MSE_Synthetic_vsV_%s_w=%d_m=%d_R=%d_eps=%g.mat', ...
        Type, w, m, R, eps));

    save(outfile, ...
        'w', 'm', 'R', 'eps', 'Type', 'vList', ...
        'mse_uRR','mse_uRAP','mse_uOUE','mse_uHR','mse_uSS','mse_opt', ...
        'mse_noPriv', '-v7.3');

    fprintf('Saved : %s\n', outfile);
end