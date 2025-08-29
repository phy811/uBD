function [M, J1, J2, J3] = compute_M_J(alpha, t, w, v, epsilon)
    % Compute M, J given alpha, t, w, v, epsilon
    % alpha \in [0,1]
    % t \in \Delta_v
    % w : |\mathcal{X}|
    % v : |\mathcal{X}_S|
    % epsilon : privacy constraint
    %======================================================================
    expEps = exp(epsilon);
    k = (1 : v)';
    J1 = (v * (expEps - 1) ^ 2) / (v - 1) * sum(t .* (k .* (v-k)) ...
        ./ ((alpha * k * (expEps - 1) + v) .* (k * expEps + v - k)));
    J2 = ((w-v) * (expEps-1) / (1 - alpha)) * sum(t .* k ...
        ./ (k * expEps + v - k));
    J3 = (v * (w - v) * (expEps - 1) / (w * (1 - alpha))) * sum(t .* k ...
        ./ (alpha * k * (expEps - 1) + v));

    M = (v-1) / J1 + (w-v-1) / J2 + 1 / J3;
end