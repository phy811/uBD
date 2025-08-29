function [alpha_opt, t_opt, M_val] = optimize_M(w, v, epsilon)
    % Compute 
    % M(w,v,epsilon) = \sup_{alpha \in [0,1]} \inf_{t \in \Delta_v} f
    % Uses nested optimization: inner minimization over t, 
    % outer maximization over alpha
    % w : |\mathcal{X}|
    % v : |\mathcal{X}_S|
    % epsilon : privacy constraint
    %======================================================================
    % Options for inner fmincon (t optimization)
    inner_opts = optimoptions('fmincon', 'Display', 'off', 'Algorithm',...
        'sqp');

    % Objective for alpha: returns -inf_t f(alpha,t)
    obj_alpha = @(alpha) -inner_min_t(alpha, w, v, epsilon, inner_opts);

    % Outer maximize via fminbnd (minimize the negative)
    alpha_opt = fminbnd(obj_alpha, 0, 1);

    % Recover optimal t and M_val
    M_val = inner_min_t(alpha_opt, w, v, epsilon, inner_opts);
    
    % inner_min_t returns min_t f
    [~, t_opt] = inner_min_t(alpha_opt, w, v, epsilon, inner_opts);
    t_opt(t_opt < 1e-8) = 0;
    t_opt = t_opt/sum(t_opt);
end

%==========================================================================
function [Mmin_val, t_star] = inner_min_t(alpha, w, v, epsilon, opts)
    % Compute inf_{t in Delta_v} f(alpha,t)
    % alpha \in [0, 1]
    % w : |\mathcal{X}|
    % v : |\mathcal{X}_S|
    % epsilon : privacy constraint
    % opts : options
    % Mmin_val : \min_t f, t_star : \argmin_t f
    %======================================================================
    % Initial guess: uniform t
    t0 = ones(v, 1) / v;

    % Constraints: sum(t) = 1, t >= 0
    Aeq = ones(1, v); 
    beq = 1;
    lb = zeros(v, 1); 
    ub = ones(v, 1);

    % t-only objective
    obj_t = @(t) compute_M_J(alpha, t, w, v, epsilon);

    % Solve inner problem
    [t_star, Mmin_val] = fmincon(obj_t, t0, [], [], Aeq, beq, lb, ub,...
        [], opts);
end
