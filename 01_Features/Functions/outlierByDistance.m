function [out, tabOut] = outlierByDistance(data)
%
% This function measures distances between mouse's bodyparts to determine
% if DLC track is correct 
%
% Input: data from bodyparts in centimeters, in the standard order
%
% Output: true if it is an outlier (wrong track) and false if the track is
%         correct.
%

out = false;

nasX = data(:,1);     nasY = data(:,2);
culX = data(:,5);     culY = data(:,6);
ficuaX = data(:,9);   ficuaY = data(:,10);
potaEX = data(:,11);  potaEY = data(:,12);
potaDX = data(:,13);  potaDY = data(:,14);
potaeX = data(:,17);  potaeY = data(:,18);
potadX = data(:,19);  potadY = data(:,20);

d1 = sqrt((nasX-culX).^2 + (nasY-culY).^2);
d2 = sqrt((nasX-potaEX).^2 + (nasY-potaEY).^2);
d3 = sqrt((nasX-potaDX).^2 + (nasY-potaDY).^2);
d4 = sqrt((culX-potaeX).^2 + (culY-potaeY).^2);
d5 = sqrt((culX-potadX).^2 + (culY-potadY).^2);
d6 = sqrt((culX-ficuaX).^2 + (culY-ficuaY).^2);

f1 = sum(d1>11);     f2 = sum(d2>8);      f3 = sum(d3>8);
f4 = sum(d4>6);      f5 = sum(d5>6);      f6 = sum(d6>12);

ft = length(nasX);

tabOut = [f1 f2 f3 f4 f5 f6 ft];

if any([f1 f2 f3 f4 f5 f6]./ft > 0.1)
    out = true;
end
end