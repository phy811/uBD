function axInset = addInsetZoom(ax, xrange, yrange, pos, opts)
    arguments
        ax (1,1) matlab.graphics.axis.Axes
        xrange (1,2) double
        yrange (1,2) double
        pos (1,4) double
        opts.BoxColor = 'r'
        opts.BoxLineWidth (1,1) double = 1.2
        opts.BoxLineStyle char = '--'
    end

    fig = ancestor(ax,'figure');
    if ~strcmpi(fig.Renderer,'opengl'), set(fig,'Renderer','opengl'); end

    hold(ax,'on');

    parentContainer = ax.Parent;   
    axInset = axes('Parent', parentContainer, ...
                   'Position', pos, 'Color','w', 'Box','on'); 
    hold(axInset,'on');
    
    axInset.XScale = ax.XScale;
    axInset.YScale = ax.YScale;
    copyobj(allchild(ax), axInset);

    xlim(axInset, xrange);
    ylim(axInset, yrange);

    rectangle(ax,'Position',[xrange(1), yrange(1), diff(xrange), diff(yrange)], ...
    'EdgeColor',opts.BoxColor,'LineWidth',opts.BoxLineWidth,'LineStyle',opts.BoxLineStyle);
    grid(axInset, 'on')
    axInset.Layer = 'top';
    axInset.LineWidth = 0.8;
    axInset.FontSize = max(ax.FontSize-2, 8);
    axInset.ActivePositionProperty = 'position'; 

    uistack(axInset,'top');
    try uistack(parentContainer,'top'); catch, end

    lgdInset = findobj(fig,'Type','Legend','-and','AssociatedAxes',axInset);
    if ~isempty(lgdInset), delete(lgdInset); end
end