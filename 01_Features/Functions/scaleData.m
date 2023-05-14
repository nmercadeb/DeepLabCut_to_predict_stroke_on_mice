function data = scaleData (nomvideo, nomxlsx, csvcapsa)
%
% This function scalate data from pixels to centimeters and redefine
% prespective to the cage plane. Experimental set-up data is 25cm square 
% cage.
%
% Inputs: 
%  - dada: matrix containing the coordinates x, y and z=1 for a label
%          throughout the video. Origin
%  - nomvideo: path to the video analyzed with DLC
%  - SE,SD,IE,ID: coorner coodinates obatined with the function corners.m
% Outputs:
%  - newdadaX: vector with coordinates of the X axis
%  - newdadaY: vector with coordinates of the Y axis

[SE, SD, IE, ID] = corners (nomvideo, csvcapsa);

un     = [SE(1); SE(2); 1]; % Upper left
dos    = [SD(1); SD(2); 1]; % Upper right
tres   = [IE(1); IE(2); 1]; % Lower left
quatre = [ID(1); ID(2); 1]; % Lower right

% Solve linear system A*b = c
A = [un, dos, tres]; c = quatre; b = (A\c)';

% A projects the canonical basis into a multiple of vectors un, dos, tres
% respectively, and the vector [1 1 1] is projected into a multiple of
% quatre.
A = [A(:,1).*b(1), A(:,2).*b(2), A(:,3).*b(3)];

% Square box in centimeters:
unc     = [0; 25; 1];   % Upper left
dosc    = [25; 25; 1];  % Upper right
tresc   = [0; 0; 1];    % Lower left
quatrec = [25; 0; 1];   % Lower right

Ac = [unc, dosc, tresc];
cc = quatrec;
bc = (Ac\cc)';
B  = [Ac(:,1).*bc(1), Ac(:,2).*bc(2), Ac(:,3).*bc(3)];


t = readtable(nomxlsx);
t = table2array(t(:,2:end));

[r,c] = size(t);
data = nan(r,c/2);

for k = 1:c/2
    scalated3d = B*inv(A)*[t(:,k*2-1) t(:,k*2) ones(r,1)]';
    data(:,k*2-1:k*2) = [scalated3d(1,:)' scalated3d(2,:)']./scalated3d(3,:)';
end
end