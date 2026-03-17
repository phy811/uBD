function [pTrue, Data] = Generate_Synt_Data(w, n, Type)
    here = fileparts(mfilename('fullpath'));
    addpath(genpath(here));

    i = (1:w)';
    switch Type
        case "unif"
            pTrue = ones(w, 1) / w;
        case "zipf"
            zipfS = 1;
            p = i.^ (-zipfS);
            pTrue = p / sum(p);
        case "geo"
            lambda = 0.05;
            p = (1 - lambda).^(i - 1) * lambda;
            pTrue = p / sum(p);
    end

    cdf = cumsum(pTrue);
    cdf(end) = 1;
    edges = [0; cdf];
    u = rand(n, 1);
    Data = discretize(u, edges);
    Data = Data(:);

    outfile = fullfile(here, sprintf('Synt_w=%d_n=%d_%s.mat', w, n, Type));
    save(outfile, 'pTrue', 'Data', '-v7.3');
    fprintf('Saved_%s.mat\n', Type);
end