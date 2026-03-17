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

% 2) Load Data (v-sweep result)
% Example file name:
%   MSE_Synthetic_vsV_geo_w=300_m=20_R=30000_eps=1.mat
%   MSE_Synthetic_vsV_geo_w=300_m=20_R=30000_eps=6.mat
%   MSE_Synthetic_vsV_zipf_w=300_m=20_R=30000_eps=1.mat
%   MSE_Synthetic_vsV_zipf_w=300_m=20_R=30000_eps=6.mat
%==========================================================================

fname = 'MSE_Synthetic_vsV_geo_w=300_m=20_R=30000_eps=6.mat';
D = load(fname, ...
            'w', 'm', 'R', 'eps', 'Type', 'vList', ...
            'mse_uRR','mse_uRAP','mse_uOUE','mse_uHR','mse_uSS','mse_opt', ...
            'mse_noPriv');

vList = D.vList(:).';   % row vector for plotting
nPts  = numel(vList);

mseAll = {D.mse_uRR, D.mse_uRAP, D.mse_uOUE, D.mse_uHR, D.mse_uSS, D.mse_opt};

y_np = mean(D.mse_noPriv);

labels    = {'uRR','uRAP','uOUE','uHR','uSS','uBD'};
markers   = {'o','s','^','d','>','v'};
colors    = lines(numel(labels));
markerIdx = unique(round(linspace(1, nPts, min(10,nPts))));
alphaBand = 0.1;

% 3) Plot Results (Legend-only + Main figure)
%==========================================================================
figLeg = figure(1);
figLeg.Position = [100 100 500 60];
clf(figLeg);
ax = axes(figLeg, 'Visible','off');
hold(ax,'on');

dummy = gobjects(numel(labels)+1,1);
for i = 1:numel(labels)
    dummy(i) = plot(ax, NaN, NaN, ...
        'LineWidth', 1.2, ...
        'Marker', markers{i}, ...
        'MarkerFaceColor', colors(i,:), ...
        'Color', colors(i,:), ...
        'DisplayName', labels{i});
end
dummy(end) = plot(ax, NaN, NaN, '--k', 'DisplayName', 'No privacy');

legend(ax, dummy, 'Orientation','horizontal', ...
    'Location','northoutside', 'FontSize',12, ...
    'Box','on', 'NumColumns',4);
ax.Visible = 'off';

fig = figure(2);
fig.Position = [100 100 400 350];
clf(fig);
hold on; grid on; box on;

x = vList;

for i = 1:numel(labels)
    y = mean(mseAll{i}, 2);
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
    hold on;

    semilogy(x, y, ...
        'Color',           colors(i,:), ...
        'Marker',          markers{i}, ...
        'MarkerFaceColor', colors(i,:), ...
        'MarkerIndices',   markerIdx, ...
        'LineWidth',       1.2, ...
        'MarkerSize',      6, ...
        'DisplayName',     labels{i});
end

% Non-private baseline (constant wrt v)
yline(y_np, '--k', 'LineWidth', 1.2, 'HandleVisibility','off');

switch true
    case contains(fname,'geo') && contains(fname, 'eps=1')
        axisSettings = struct( ...
        'ylim', {[-0.1e-2, 3e-2]}, ...
        'exp',  {-2} ...
        );
        ZoomCfg = struct('pos', [0.5 0.5 0.36 0.36], ...
            'x', [100 200], 'y', [0.5e-2  1.1e-2]);
    case contains(fname,'geo') && contains(fname, 'eps=6')
        axisSettings = struct( ...
        'ylim', {[-0.2e-3, 6e-3]}, ...
        'exp',  {-3} ...
        );
        ZoomCfg = struct('pos', [0.18 0.5 0.36 0.36], ...
            'x', [100 200], 'y', [0.4e-4 0.8e-4]);
    case contains(fname,'zipf') && contains(fname, 'eps=1')
        axisSettings = struct( ...
        'ylim', {[-0.1e-2, 4e-2]}, ...
        'exp',  {-2} ...
        );
        ZoomCfg = struct('pos', [0.5 0.5 0.36 0.36], ...
            'x', [100 200], 'y', [5e-3 14e-3]);
    case contains(fname,'zipf') && contains(fname, 'eps=6')
        axisSettings = struct( ...
        'ylim', {[-0.3e-3, 8e-3]}, ...
        'exp',  {-3} ...
        );
        ZoomCfg = struct('pos', [0.18 0.5 0.36 0.36], ...
            'x', [100 200], 'y', [0  0.15e-3]);
end
% Apply axis settings
ylim(axisSettings.ylim);
ax = gca;
ax.YAxis.Exponent = axisSettings.exp;

xlim([min(x), max(x)]);
xlabel('$v$');
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