function Save_MSE_Synt(w, v, n, m, R, nPts, Type)
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
    params.XS = 1:v;

    if v == 2
        epsL = log(1 + sqrt(2*(w-2)/(w-1)));
    else
        epsL = log(sqrt((v-1)*(v-2)/2));
    end
    epsH = log(w - v + sqrt((w-1)*(w-2)/2));
        
    epsRange = [0.1  epsL;
                epsL epsH;
                epsH 10];

    % Allocation
    %-----------------------------
    mse_uRR  = zeros(3, nPts, m);
    mse_uRAP = zeros(3, nPts, m);
    mse_uOUE = zeros(3, nPts, m);
    mse_uHR  = zeros(3, nPts, m);
    mse_uSS  = zeros(3, nPts, m);
    mse_opt  = zeros(3, nPts, m);
    mse_noPriv = zeros(3, m);

    for s = 1:3
        epsList = linspace(epsRange(s,1), epsRange(s,2), nPts);
    
        for r = 1:m
            sub = Data(subsampIdx(r,:));
            pHat_np = accumarray(sub,1,[w 1])/R;
            mse_noPriv(s,r) = sum((pHat_np-pTrue).^2);
        end

        for k = 1:nPts
            lp = params; lp.eps = epsList(k);
            [opt_alpha, opt_t, ~] = optimize_M(w, v, lp.eps);
            lp.alpha = opt_alpha;
            lp.t = opt_t;
            lp.k = find_opt_k_uSS(v, exp(epsList(k)));
    
            for r = 1:m
                sub = Data(subsampIdx(r,:));
                mse_uRR(s, k, r) = computeMSE(@encode_uRR, @decode_uRR,...
                    sub, lp, pTrue);
                mse_uRAP(s, k, r) = computeMSE(@encode_uRAP, @decode_uRAP,...
                    sub,lp,pTrue);
                mse_uOUE(s, k, r) = computeMSE(@encode_uOUE, @decode_uOUE,...
                    sub, lp, pTrue);
                mse_uHR(s, k, r) = computeMSE(@encode_uHR, @decode_uHR,...
                    sub, lp, pTrue);
                mse_uSS(s, k, r) = computeMSE(@encode_uSS, @decode_uSS,...
                    sub, lp, pTrue);
                mse_opt(s, k, r) = computeMSE(@encode_opt_ULDP,...
                    @decode_opt_ULDP, sub, lp, pTrue);
            end
            fprintf('[%s] seg %d/3, eps %d/%d (%.4f) done\n', ...
                Type, s, k, nPts, epsList(k));
        end
    end

    % Save MSE
    outfile = sprintf('MSE_Synthetic_%s_R%d_m%d_nPts%d.mat',Type,R,m,nPts);
    save(outfile,...
          'epsRange','nPts', ...
          'mse_uRR','mse_uRAP','mse_uOUE','mse_uHR','mse_uSS', ...
          'mse_opt','mse_noPriv', '-v7.3');
    fprintf('Saved per-run MSE_%s.mat\n', lower(combtype));
end