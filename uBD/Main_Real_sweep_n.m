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
% fname : 
%   'MSE_vsN_and_eps1_m20.mat', 'MSE_vsN_and_eps5_m20.mat', 'MSE_vsN_and_eps8_m20.mat',
%   'MSE_vsN_or_eps1_m20.mat', 'MSE_vsN_or_eps5.3_m20.mat', 'MSE_vsN_or_eps8_m20.mat',
%==========================================================================

fname = 'MSE_vsN_or_eps8_m20.mat';
D = load(fname, ...
    'RList','m', 'eps', ...
    'mse_uRR','mse_uRAP','mse_uOUE','mse_uHR','mse_uSS','mse_opt');

RList = D.RList(:)';   % row vector
mseAll = {D.mse_uRR, D.mse_uRAP, D.mse_uOUE, D.mse_uHR, D.mse_uSS, D.mse_opt};

labels    = {'uRR','uRAP','uOUE','uHR','uSS','uBD'};
markers   = {'o','s','^','d','>','v'};
colors    = lines(numel(labels));
markerIdx = unique(round(linspace(1, numel(RList), min(10, numel(RList)))));
alphaBand = 0.10;

% Pre-allocate handles for legend (taken from the first figure only)
hPlots = gobjects(numel(labels),1);

% 3) Legend-only figure
figLeg = figure(1);
figLeg.Position = [100 100 500 60];
clf(figLeg);
axLeg = axes(figLeg, 'Visible', 'off');
hold(axLeg, 'on');

dummy = gobjects(numel(labels),1);
for i = 1:numel(labels)
    dummy(i) = plot(axLeg, NaN, NaN, ...
        'LineWidth', 1.2, ...
        'Marker', markers{i}, ...
        'MarkerFaceColor', colors(i,:), ...
        'Color', colors(i,:), ...
        'DisplayName', labels{i});
end

legend(axLeg, dummy, 'Orientation','horizontal', ...
    'Location','northoutside', 'FontSize',12, 'Box','on', 'NumColumns',4);
axLeg.Visible = 'off';

% 4) Main figure
fig = figure(2);
fig.Position = [100 100 400 350];
clf(fig);
hold on; grid on; box on;

x = RList;   % sample size

for i = 1:numel(labels)
    y = mean(mseAll{i}, 2);      % [nR x 1]
    y = y(:).';
    err = std(mseAll{i}, 0, 2);
    err = err(:).';

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

switch true
    case contains(fname,'_and_eps1')
        axisSettings = struct( ...
        'ylim', {[0, 1.5e-2]}, ...
        'exp',  {-2} ...
        );
        ZoomCfg = struct('pos', [0.5 0.5 0.36 0.36], ...
            'x', [3.5e4 5.5e4], 'y', [0.08e-2  0.25e-2]);
    case contains(fname,'_and_eps5')
        axisSettings = struct( ...
        'ylim', {[0, 4e-4]}, ...
        'exp',  {-4} ...
        );
        ZoomCfg = struct('pos', [0.5 0.5 0.36 0.36], ...
            'x', [3.5e4 5.5e4], 'y', [2e-5 5e-5]);
    case contains(fname,'_and_eps8')
        axisSettings = struct( ...
        'ylim', {[0, 3e-4]}, ...
        'exp',  {-4} ...
        );
        ZoomCfg = struct('pos', [0.5 0.5 0.36 0.36], ...
            'x', [3.5e4 5.5e4], 'y', [1e-5 5e-5]);
    case contains(fname,'_or_eps1')
        axisSettings = struct( ...
        'ylim', {[0, 3e-2]}, ...
        'exp',  {-2} ...
        );
        ZoomCfg = struct('pos', [0.5 0.5 0.36 0.36], ...
            'x', [3.5e4 5.5e4], 'y', [0.6e-2  1e-2]);
    case contains(fname,'_or_eps5.3')
        axisSettings = struct( ...
        'ylim', {[0, 8e-3]}, ...
        'exp',  {-3} ...
        );
        ZoomCfg = struct('pos', [0.5 0.5 0.36 0.36], ...
            'x', [3.5e4 5.5e4], 'y', [0  0.2e-3]);
    case contains(fname,'_or_eps8')
        axisSettings = struct( ...
        'ylim', {[0, 8e-3]}, ...
        'exp',  {-3} ...
        );
        ZoomCfg = struct('pos', [0.5 0.5 0.36 0.36], ...
            'x', [3.5e4 5.5e4], 'y', [0  0.2e-3]);
end
% Apply axis settings
ylim(axisSettings.ylim);
ax = gca;
ax.YAxis.Exponent = axisSettings.exp;

xlim([min(x), max(x)]);
xlabel('$n$');
ylabel('MSE');

cfg = ZoomCfg;
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