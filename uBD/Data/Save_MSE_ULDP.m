function Save_MSE_ULDP(combtype, R, m, nPts)
    %======================================================================
    %  Compute MSE curves for five ULDP mechanisms and SAVE to disk.
    %  ─ No plotting here. Result file:  MSE_<combtype>.mat
    %  combtype : 'and' | 'or'   (pre-processed file  Data_<combtype>.mat )
    %  R : bootstrap sample size (e.g. 7e4)
    %  m : #bootstrap replicates (e.g. 10)
    %  nPts : #epsilon grid points per interval (e.g. 100)
    %======================================================================
    addpath(genpath('C:\Users\Yoon Sunmoon\Desktop\uBD\ULDP scheme'));
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
    
    % Epsilon ranges
    epsL = log(sqrt((v-1)*(v-2)/2));
    epsH = log(w-v + sqrt((w-1)*(w-2)/2));
    epsRange = [0.1 epsL;   epsL epsH;   epsH 10];    % 3 세그먼트
    
    % Subsample data
    rng(1,'twister');
    subsampIdx = reshape(randperm(nTotal, m*R), m, R);   % m×R
    
    % Allocation
    mse_uRR  = zeros(3,nPts,m);
    mse_uRAP = zeros(3,nPts,m);
    mse_uOUE = zeros(3,nPts,m);
    mse_uHR  = zeros(3,nPts,m);
    mse_opt  = zeros(3,nPts,m);
    mse_noPriv = zeros(3, m);
    
    % Main loop
    for s = 1:3
        epsList = linspace(epsRange(s,1), epsRange(s,2), nPts);
    
        for r = 1:m
            sub = rawData(subsampIdx(r,:));
            pHat_np = accumarray(sub,1,[w 1])/R;
            mse_noPriv(s,r) = mean((pHat_np-pTrue).^2);
        end
        for k = 1:nPts
            lp = params; lp.eps = epsList(k);
            [opt_alpha, opt_t, ~] = optimize_M(w, v, lp.eps);
            lp.alpha = opt_alpha;
            lp.t = opt_t;
    
            for r = 1:m
                sub = rawData(subsampIdx(r,:));
                mse_uRR(s,k,r) = computeMSE(@encode_uRR, @decode_uRR,...
                    sub, lp, pTrue);
                mse_uRAP(s,k,r) = computeMSE(@encode_uRAP, @decode_uRAP,...
                    sub,lp,pTrue);
                mse_uOUE(s,k,r) = computeMSE(@encode_uOUE, @decode_uOUE,...
                    sub, lp, pTrue);
                mse_uHR(s,k,r) = computeMSE(@encode_uHR, @decode_uHR,...
                    sub,lp,pTrue);
                mse_opt(s,k,r) = computeMSE(@encode_opt_ULDP,...
                    @decode_opt_ULDP,...
                    sub,lp,pTrue);
            end
        end
    end
    
    % Save MSE
    outfile = sprintf('MSE_%s_R%d_m%d.mat',lower(combtype),R,m);
    save(outfile,...
          'epsRange','nPts', ...
          'mse_uRR','mse_uRAP','mse_uOUE','mse_uHR','mse_opt','mse_noPriv', ...
          '-v7.3');
    fprintf('Saved per-run MSE_%s.mat\n', lower(combtype));
end