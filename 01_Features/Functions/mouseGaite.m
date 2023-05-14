function table = mouseGaite(B,nomvideo,nomv)
%
% This function gathers gaite data from the mouse.
%
% Inputs: 
%  - B: data from bodyparts in centimeters, in the standard order
%  - nomvideo: path to the video
%  - nomv: name of the video file (without '.mp4')
%
% Output
%  - table: ['Distance travelled', 'Moving time', 'Mean nose velocity' ...
%            'Mean bottom velocity', 'Mean tail velocity', ...
%            'Mean FI paw velocity', 'Mean FC paw velocity' ...
%            'Mean HI paw velocity', 'Mean HC paw velocity' ...
%            'Mean velocity when moving', 'Distance between Fpaws', 'Distance between Hpaws' ...
%            'Mouse length', 'Time tail I' ...
%            'Time tail C', 'Time straight tail', 'Time body I' ...
%            'Time body C', 'Time straight body']

% Video
video = VideoReader(nomvideo);
fps   = video.NumFrames/video.Duration;

B = B'; % Each row is a bodypart
% Body parts
nasX    = B(1,:);    nasY    = B(2,:); 
collX   = B(3,:);    collY   = B(4,:); 
culX    = B(5,:);    culY    = B(6,:); 
midcuaX = B(7,:);    midcuaY = B(8,:); 
ficuaX  = B(9,:);    ficuaY  = B(10,:); 
potaEX  = B(11,:);   potaEY  = B(12,:); 
potaDX  = B(13,:);   potaDY  = B(14,:); 
potaeX  = B(17,:);   potaeY  = B(18,:); 
potadX  = B(19,:);   potadY  = B(20,:); 

% Output matrix
table = zeros(1,20);

% Butt
cul   = [culX; culY]; 

% Frames in which there's movement
index = 1; k = 1; TOL = .5;
while(index(end)+k <= length(cul(1,:)))
    if norm([cul(1, index(end)) - cul(1, index(end)+k), cul(2,index(end)) - cul(2,index(end)+k)]) < TOL
        k = k+1; % there's no movment between frames
    else
        index = [index index(end)+k]; k = 1;
    end
end

culm     = [cul(1,index); cul(2, index)]; % Butt positions in which there's movement
moviment = culm(:,2:end) - culm(:,1:end-1); 

recorregut = 0;
for i = 1:length(moviment(1,:))
    recorregut = recorregut + sqrt(moviment(1,i)^2 + moviment(2,i)^2);
end
table(1) = recorregut;

% Percentatge of time moving:
actiu = (length(culm)/length(cul))*100;
table(2) = actiu;


% Classify mice depending on which side there's the ligature
left  = [629, 631, 633, 634, 636, 637, 645, 654];
right = [638, 639, 640, 641, 642, 643, 644, 646, 647, 648, 649, 650, 651, 652, 653, 655, 656, 657];

% Average velocities
ini=strfind(nomv,'(6');
if ismember(eval(nomv(ini+1:ini+3)),left) 
    varnames  = ["nas","cul","ficua","potaE","potaD","potae", "potad","culm"];
elseif ismember(eval(nomv(ini+1:ini+3)),right)
    varnames  = ["nas","cul","ficua","potaD","potaE","potad", "potae","culm"]; % canviat l'ordre respecte l'esquerra
end

culmX = culm(1,:); culmY = culm(2,:);

for k = 1:length(varnames)
    eval (['v= sqrt ((' varnames{k} 'X(2:end)-' varnames{k} 'X(1:end-1)).^2+(' varnames{k} 'Y(2:end)-' varnames{k} 'Y(1:end-1)).^2)*fps;']);
    vm = mean (v);
    table(k+2) = vm;
end

% Plots distàncies, distàncies interessants: entre potes, cul-nas
table(11) = mean(sqrt((potaEX-potaDX).^2+(potaEY-potaDY).^2));
table(12) = mean(sqrt((potaeX-potadX).^2+(potaeY-potadY).^2));
table(13) = mean(sqrt((nasX-culX).^2+(nasY-culY).^2));


% TAIL CURVATURE -------------------
v1 = [midcuaX-culX; midcuaY-culY];     % butt to mid tail
v2 = [ficuaX-midcuaX; ficuaY-midcuaY]; % mid tail to end tail

v1 = v1./vecnorm(v1);         v2 = v2./vecnorm(v2);

theta = acosd(dot(-v1,v2));

cros = v1(1,:).*v2(2,:) - v1(2,:).*v2(1,:);

% Curved if theta > 165; curved to the left if cros<0
indexCurved = theta >= 165;

ft = video.NumFrames;              % total number of frames
fr = sum(~indexCurved)/ft;         % frames tail straigth
fd = sum(indexCurved & cros>0)/ft; % frames tail to the right
fe = sum(indexCurved & cros<0)/ft; % frames tail to the left


% BODY CURVATURE -------------------
v11 = [collX-nasX; collY-nasY];     % butt to mid tail
v22 = [culX-collX; culY-collY]; % mid tail to end tail

v11 = v11./vecnorm(v11);         v22 = v22./vecnorm(v22);

alpha = acosd(dot(-v11,v22));

crs = v11(1,:).*v22(2,:) - v11(2,:).*v22(1,:);

% Curved if theta > 165; curved to the left if cros<0
indCurved = alpha >= 165;

frr = sum(~indCurved)/ft;        % frames tail straigth
fdd = sum(indCurved & crs>0)/ft; % frames tail to the right
fee = sum(indCurved & crs<0)/ft; % frames tail to the left

% C, I, R
if ismember(eval(nomv(ini+1:ini+3)),left) 
    table(14:end-1) = [fd, fe, fr, fdd, fee, frr].*100;
elseif ismember(eval(nomv(ini+1:ini+3)),right)
    table(14:end-1) = [fe, fd, fr, fee, fdd, frr].*100;
end

table(end) = video.Duration;
end