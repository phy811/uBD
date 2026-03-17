function [xn, yn] = data2fig(ax, x, y)
    fig = ancestor(ax,'figure');
    axpos = getpixelposition(ax, true);    % [x y w h] in fig pixels
    figpos = getpixelposition(fig, true);  % fig size in pixels

    xl = xlim(ax);
    if strcmpi(ax.XScale,'log')
        rx = (log10(x)-log10(xl(1))) / (log10(xl(2))-log10(xl(1)));
    else
        rx = (x-xl(1)) / (xl(2)-xl(1));
    end

    yl = ylim(ax);
    if strcmpi(ax.YScale,'log')
        ry = (log10(y)-log10(yl(1))) / (log10(yl(2))-log10(yl(1)));
    else
        ry = (y-yl(1)) / (yl(2)-yl(1));
    end

    % fig normalized
    xp = axpos(1) + rx*axpos(3);
    yp = axpos(2) + ry*axpos(4);
    xn = xp / figpos(3);
    yn = yp / figpos(4);
end
