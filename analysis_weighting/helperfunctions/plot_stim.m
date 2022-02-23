

function [xunit, yunit] = plot_stim(r,cent)
% plots stimulus circle with radius = r
x = cent(1); y=cent(2);
th = 0:pi/50:2*pi;
if numel(r) == 1
    xunit = r * cos(th) + x;
    yunit = r * sin(th) + y;
elseif numel(r) == 2
    xunit = r(1) * cos(th) + x;
    yunit = r(2) * sin(th) + y;
end
end