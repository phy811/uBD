function [xn, yn] = insetAnchor2fig(axInset, anchor)
% anchor: 'nw','ne','sw','se','wmid','emid','nmid','smid','center'
    fig = ancestor(axInset,'figure');
    ip = getpixelposition(axInset, true);  % inset in fig pixels [x y w h]
    switch lower(anchor)
        case 'nw',  xp = ip(1);               yp = ip(2)+ip(4);
        case 'ne',  xp = ip(1)+ip(3);         yp = ip(2)+ip(4);
        case 'sw',  xp = ip(1);               yp = ip(2);
        case 'se',  xp = ip(1)+ip(3);         yp = ip(2);
        case 'wmid',xp = ip(1);               yp = ip(2)+ip(4)/2;
        case 'emid',xp = ip(1)+ip(3);         yp = ip(2)+ip(4)/2;
        case 'nmid',xp = ip(1)+ip(3)/2;       yp = ip(2)+ip(4);
        case 'smid',xp = ip(1)+ip(3)/2;       yp = ip(2);
        case 'center', xp=ip(1)+ip(3)/2;      yp=ip(2)+ip(4)/2;
        otherwise, error('Unknown anchor');
    end
    fp = getpixelposition(fig, true);
    xn = xp / fp(3);
    yn = yp / fp(4);
end