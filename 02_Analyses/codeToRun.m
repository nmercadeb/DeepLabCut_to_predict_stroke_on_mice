clear all, close all

% Computer system ----
windows = true;

% Folders ----
projectFolder          = 'projectCodes';  % Folder containing all codes and data
featuresDataFolder     = '01_Features';   % Folder were deeplabcut (DLC) is stored
analysesFolder         = '02_Analyses';
experimentalDataFolder = 'ExperimentalData';

% Jobs ----
% Set to true the jobs you want to run:
runStatisticalAnalysis = false;
runStrokeModel         = false;

% Main ----
path=cd;
id = strfind(path,projectFolder);

if windows    
    dades = readtable([path(1:id-1) projectFolder '\' featuresDataFolder '\dades.xlsx'],'Range','A1:AE563');
else
    dades = readtable([path(1:id-1) projectFolder '/' featuresDataFolder '/dades.xlsx'],'Range','A1:AE563');
end

addpath('./Functions')

if runStatisticalAnalysis, statisticalAnalysis,  end
if runStrokeModel, strokeModel, end
