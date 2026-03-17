here = fileparts(mfilename('fullpath'));
addpath(genpath(here));

% 1) Style Settings
% Configure default fonts, interpreters, 
% and sizes for consistent figure appearance
%==========================================================================
clear; clc;
set(groot, 'defaultTextInterpreter',              'latex');
set(groot, 'defaultAxesTickLabelInterpreter',     'latex');
set(groot, 'defaultLegendInterpreter',            'latex');
set(groot, 'defaultColorbarTickLabelInterpreter', 'latex');
set(groot, 'defaultAxesFontName',    'Computer Modern');
set(groot, 'defaultTextFontName',    'Computer Modern');
set(groot, 'defaultLegendFontName',  'Computer Modern');
set(groot, 'defaultAxesFontSize',    12);
set(groot, 'defaultTextFontSize',    12);
set(groot, 'defaultLegendFontSize',  12);

% 2) Load Data
% Import MSE results for different mechanisms 
% and prepare plotting parameters
% fname : 'MSE_and_R50000_m20_nPts50.mat' or 'MSE_or_R50000_m20_nPts50.mat'
%==========================================================================

fname = 'MSE_or_R50000_m20_nPts50.mat';
D = load(fname, ...
     'epsRange','nPts', ...
     'mse_uRR','mse_uRAP','mse_uOUE','mse_uHR','mse_uSS','mse_opt','mse_noPriv');

epsRange = D.epsRange;   % 3 × 2 array of epsilon ranges
nPts     = D.nPts;
mseAll   = {D.mse_uRR, D.mse_uRAP, D.mse_uOUE, D.mse_uHR, D.mse_uSS, D.mse_opt};
y_np     = mean(D.mse_noPriv, 2);   % mean of non-private baseline, 3 × 1

labels    = {'uRR','uRAP','uOUE','uHR','uSS','uBD'};
markers   = {'o','s','^','d','>','v'};
colors    = lines(numel(labels));
markerIdx = round(linspace(1, nPts, 10));
alphaBand = 0.1;

% Pre-allocate handles for legend (taken from the first figure only)
hPlots = gobjects(numel(labels),1);

%3) Plot Results per Segment
%Generate three separate figures corresponding to different epsilon ranges
%==========================================================================

for sFig = 1:4
    % Legend only figure
    if sFig == 1
        figLeg = figure(1);
        figLeg.Position = [100 100 500 60];
        clf(figLeg);
        ax = axes(figLeg, 'Visible','off'); 
        hold(ax,'on');

        dummy = gobjects(numel(labels)+1,1);
        for i = 1:numel(labels)
        dummy(i) = plot(ax, NaN,NaN, 'LineWidth',1.2, ...
            'Marker', markers{i}, 'MarkerFaceColor', colors(i,:),...
            'Color', colors(i, :),...
            'DisplayName', labels{i}); 
        end
        dummy(end) = plot(ax, NaN,NaN, '--k', 'DisplayName','No privacy');

        legend(ax, dummy, 'Orientation','horizontal', ...
            'Location','northoutside', 'FontSize',12, 'Box','on','NumColumns',4);
        ax.Visible = 'off';

    else
        seg = sFig - 1;
        fig = figure(sFig);
        fig.Position  = [100 100 400 350];
        clf(fig);
        hold on; grid on; box on;
    
        x = linspace(epsRange(seg,1), epsRange(seg,2), nPts);
    
        for i = 1:numel(labels)
            y   = squeeze(mean(mseAll{i}(seg,:,:), 3));
            err = squeeze(std(mseAll{i}(seg,:,:), 0, 3));
        
            % Error band (mean ± std)
            x2 = [x, fliplr(x)];
            y2 = [y+err, fliplr(y-err)];
            fill(x2, y2, colors(i,:), ...
                'FaceAlpha', alphaBand, ...
                'EdgeColor', 'none', ...
                'HandleVisibility','off');
        
            % Mean curve with markers
            semilogy(x, y, ...
                'Color',           colors(i,:), ...
                'Marker',          markers{i}, ...
                'MarkerFaceColor', colors(i,:), ...
                'MarkerIndices',   markerIdx, ...
                'LineWidth',       1.2, ...
                'MarkerSize',      6, ...
                'DisplayName',     labels{i});
        end

        % Non-private baseline
        yline(y_np(seg), '--k', 'LineWidth',1.2, 'HandleVisibility','off');
        
        % Axis settings for each segment
        % Define y-limits and exponent values in one place
        if contains(fname, '_and_')
            axisSettings = struct( ...
            'ylim', {[-1e-2, 8e-2], [1e-5, 25e-5], [1e-5, 12e-5]}, ...
            'exp',  {-2, -5, -5} ...
            );
            ZoomCfg(1) = struct('pos', [0.5 0.5 0.36 0.36], ...
                'x', [0.8 1.2], 'y', [0.04e-2  0.3e-2]);
            ZoomCfg(2) = struct('pos', [0.5 0.5 0.36 0.36], ...
                'x', [3.8 4.2], 'y', [4e-5  7e-5]);
            ZoomCfg(3) = struct('pos', [0.5 0.5 0.36 0.36], ...
                'x', [6.8 7.2], 'y', [1.9e-5  2.2e-5]);

        else
            axisSettings = struct( ...
                'ylim', {[-1e-3  33e-3], [-1e-4  26e-4], [-1e-4, 26e-4]}, ... 
                'exp',  {-3, -4, -4} ...
            );
            ZoomCfg(1) = struct('pos', [0.5 0.5 0.36 0.36], ...
                'x', [0.8 1.2], 'y', [5e-3  1e-2]);
            ZoomCfg(2) = struct('pos', [0.4 0.33 0.36 0.36], ...
                'x', [5.2 5.3], 'y', [0.8e-4  1.5e-4]);
            ZoomCfg(3) = struct('pos', [0.4 0.3 0.36 0.36], ...
                'x', [6.8 7.2], 'y', [0  2e-4]);
        end

        % Apply axis settings
        ylim(axisSettings(seg).ylim);
        ax = gca;
        ax.YAxis.Exponent = axisSettings(seg).exp;
    
        xlim([epsRange(seg,1), epsRange(seg,2)]);
        xlabel('$\epsilon$');
        ylabel('MSE');

        cfg = ZoomCfg(seg);
        xrange = cfg.x;
        yrange = cfg.y;
        axInset = addInsetZoom(ax, xrange, yrange, cfg.pos);
        axInset.XTick = [xrange(1) xrange(2)];
        axInset.YTick = [yrange(1) yrange(2)];
        xL = xrange(1); xR = xrange(2); yB = yrange(1); yT = yrange(2);

        [x1, y1] = data2fig(ax, xL, yT); [x2, y2] = data2fig(ax, xR, yT);   
        [u1, v1] = insetAnchor2fig(axInset, 'sw');
        [u2, v2] = insetAnchor2fig(axInset, 'se');  

        annotation(gcf,'line',[x1 u1],[y1 v1], ...
            'LineStyle','--','Color','r','LineWidth',1.2);
        annotation(gcf,'line',[x2 u2],[y2 v2], ...
            'LineStyle','--','Color','r','LineWidth',1.2);
        hold off;
    end
end