clear all, close all

% Computer system ----
windows = true;

% Folders ----
projectFolder = 'projectCodes'; % Folder containing all codes and data
DLCdata       = 'DeepLabCut';   % Folder were deeplabcut (DLC) is stored
DLCmouse      = 'TR';           % Folder with DLC data from mouse tracking
DLCbox        = 'TRC';          % Folder with DLC data from the cage

% Jobs ----
% Set to true the jobs you want to run:
runProcessDLCdata  = false;
runComputeFeatures = false;

% Main ----
path=cd;
id = strfind(path,projectFolder);

if windows
    v = dir ([path(1:id-1) projectFolder '\' DLCdata '\' DLCmouse '\**\*.mp4']);
    d = dir ([path(1:id-1) projectFolder '\' DLCdata '\' DLCmouse '\**\*.csv']);
    c = dir ([path(1:id-1) projectFolder '\' DLCdata '\' DLCbox   '\**\*.csv']);
else
    v = dir ([path(1:id-1) projectFolder '/' DLCdata '/' DLCmouse '/**/*.mp4']);
    d = dir ([path(1:id-1) projectFolder '/' DLCdata '/' DLCmouse '/**/*.csv']);
    c = dir ([path(1:id-1) projectFolder '/' DLCdata '/' DLCbox   '/**/*.csv']);
end

addpath('./Functions')

if runProcessDLCdata, processDLCdata, end

if windows
    d = dir ([path(1:id-1) projectFolder '\' DLCdata '\' DLCmouse '\**\*.xlsx']);
else
    d = dir ([path(1:id-1) projectFolder '/' DLCdata '/' DLCmouse '/**/*.xlsx']);
end

if runComputeFeatures, computeFeatures, end
