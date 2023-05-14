function [SE, SD, IE, ID] = corners (nomvideo, csvcapsa)
%
% Input parameters:
%  - nomcsv: path to the CSV file extracted from DLC (corners project)
%  - nomvideo: path to the video analyzed with DLC
% Output: 
%  - SE: upper left corner 
%  - SD: upper right corner 
%  - IE: lower left corner 
%  - ID: lower right corner 
% All coordinares in pixels, axes origin at lower right junction

video = VideoReader(nomvideo);
Y = video.Height;

tt = readtable(csvcapsa);
tt.Properties.VariableNames = {'scorer','sex','sey','Lse','sdx','sdy', ...
    'Lsd','iex','iey','Lie','idx','idy','Lid'};

% Python starts at (0,0), matlab works starting in (1,1).
id = 2:3:size(tt,2); tt{:,id} = tt{:,id}+1;
id = 3:3:size(tt,2); tt{:,id} = tt{:,id}+1;

% Box corners:
sex = tt.sex;  sey = tt.sey;  sel = tt.Lse; % Upper left
sdx = tt.sdx;  sdy = tt.sdy;  sdl = tt.Lsd; % Upper right
iex = tt.iex;  iey = tt.iey;  iel = tt.Lie; % Lower left
idx = tt.idx;  idy = tt.idy;  idl = tt.Lid; % Lower right

in = find(sel<0.7);  sex(in) = [];  sey(in) = [];
in = find(sdl<0.7);  sdx(in) = [];  sdy(in) = [];
in = find(iel<0.7);  iex(in) = [];  iey(in) = [];
in = find(idl<0.7);  idx(in) = [];  idy(in) = [];

if isempty(sex)
    sex = tt.sex;  sey = tt.sey;  sel = tt.Lse;
    m = max(sel); in = find(sel<m*0.8);
    sex(in) = [];  sey(in) = [];
elseif isempty(sdx)
    sdx = tt.sdx;  sdy = tt.sdy;  sdl = tt.Lsd;
    m = max(sdl); in = find(sdl<m*0.8);
    sdx(in) = [];  sdy(in) = [];
elseif isempty(iex)
    iex = tt.iex;  iey = tt.iey;  iel = tt.Lie;
    m = max(iel); in = find(iel<m*0.8);
    iex(in) = [];  iey(in) = [];
elseif isempty(idx)
    idx = tt.idx;  idy = tt.idy;  idl = tt.Lid;
    m = max(idl); in = find(idl<m*0.8);
    idx(in) = [];  idy(in) = [];
end

sex = smooth(sex,0.1,'rloess');   sey = smooth(sey,0.1,'rloess');
sdx = smooth(sdx,0.1,'rloess');   sdy = smooth(sdy,0.1,'rloess');
iex = smooth(iex,0.1,'rloess');   iey = smooth(iey,0.1,'rloess');
idx = smooth(idx,0.1,'rloess');   idy = smooth(idy,0.1,'rloess');

SE = [median(sex), Y - median(sey)]; SD = [median(sdx), Y - median(sdy)];
IE = [median(iex), Y - median(iey)]; ID = [median(idx), Y - median(idy)];

end