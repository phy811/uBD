function opt_k = find_opt_k_uSS(v, expEps)
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