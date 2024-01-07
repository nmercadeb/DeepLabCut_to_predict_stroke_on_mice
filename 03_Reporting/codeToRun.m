clear all, close all

% Computer system ----
windows = false;

% Folders ----
projectFolder  = 'projectCodes';     % Folder containing all codes and data
featuresData   = '01_Features';      % Folder were deeplabcut (DLC) is stored
analysesFolder = '02_Analyses';
DLCdata        = 'DeepLabCut';       % Folder were deeplabcut (DLC) is stored
DLCmouse       = 'TR';               % Folder with DLC data from mouse tracking
DLCbox         = 'TRC';              % Folder with DLC data from the cage
expResults     = 'ExperimentalData';
currentFolder  = '03_Reporting';
resultsFolder  = 'Results';

% Jobs ----
% Set to true the jobs you want to run:
runAttrition                = false;
runEvaluationFigure         = false;
runExperimentalFigure       = false;
runAnovaFigure              = false;
runMainFeaturesFigure       = false;
runIBAFigure                = false;
rungetStrokeOcurrenceFigure = false;
runSupplementaryFigure      = false;

% Main ----
path=cd;
id = strfind(path,projectFolder);

if windows
    d = dir ([path(1:id-1) projectFolder '\' DLCdata '\' DLCmouse '\**\*.csv']);
    dades    = readtable([path(1:id-1) projectFolder '\' featuresData '\dades.xlsx'],'Range','A1:AM563');
    exp_data  = readtable([path(1:id-1) projectFolder '\' expResults '\dades_model.xlsx']);
    
else
    d = dir ([path(1:id-1) projectFolder '/' DLCdata '/' DLCmouse '/**/*.csv']);
    dades    = readtable([path(1:id-1) projectFolder '/' featuresData '/dades.xlsx'],'Range','A1:AM563');
    exp_data  = readtable([path(1:id-1) projectFolder '/' expResults '/dades_model.xlsx']);
end

addpath([cd '/Functions'])

if runAttrition, getAttrition, end
if runEvaluationFigure, getEvaluationFigure, end
if runExperimentalFigure, getExperimentalFigure, end
if runAnovaFigure, getAnovaFigure, end
if runMainFeaturesFigure, getMainFeaturesFigure, end
if rungetStrokeOcurrenceFigure, getStrokeOcurrenceFigure, end
if runSupplementaryFigure, getSupplementary, end