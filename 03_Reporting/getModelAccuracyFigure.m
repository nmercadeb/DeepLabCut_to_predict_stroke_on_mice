% DATA ----

if windows
    filePath_C = [path(1:id-1) projectFolder '\' analysesFolder '\Results\BS_comp.xlsx' ];
    filePath_E = [path(1:id-1) projectFolder '\' analysesFolder '\Results\BS_exp.xlsx' ];
else
    filePath_C = [path(1:id-1) projectFolder '/' analysesFolder '/Results/BS_comp.xlsx' ];
    filePath_E = [path(1:id-1) projectFolder '/' analysesFolder '/Results/BS_exp.xlsx' ];
end

dades_comp = readtable(filePath_C, 'Sheet','Evaluation');
ObsPred_C_I = [dades_comp.Observed, dades_comp.Predicted];
ObsPred_C_G = [dades_comp.Observed_1(~isnan(dades_comp.Observed_1)), dades_comp.Predicted_1(~isnan(dades_comp.Observed_1))];

dades_exp = readtable(filePath_E, 'Sheet','Evaluation');
ObsPred_M_I = [dades_exp.Observed, dades_exp.Predicted];
ObsPred_M_G = [dades_exp.Observed_1(~isnan(dades_exp.Observed_1)), dades_exp.Predicted_1(~isnan(dades_exp.Observed_1))];


% FIGURA -----
% Comparative group computational & manual (train + test)
f = figure(1);
lx = .1; mx = .1; rx = .05; dy = .18; my = 0.1; uy = .05;
AX = get_axes_sorted([2 2],lx,mx,rx,dy,my,uy);   % lx,mx,rx,dy,my,uy

getDensityPlots(ObsPred_C_I, AX, 1, 1) % Video comp
getDensityPlots(ObsPred_M_I, AX, 1, 2) % Video exp
getDensityPlots(ObsPred_C_G, AX, 1, 3) % Mice comp
getDensityPlots(ObsPred_M_G, AX, 1, 4) % Mice exp

f.Position(3) = 700;


if windows
    print(f, [path(1:id-1) projectFolder '\' currentFolder '\' resultsFolder '\fig6_strokeModel.png'], '-r600', '-dpng')
else
    print(f, [path(1:id-1) projectFolder '/' currentFolder '/' resultsFolder '\fig6_strokeModel.png'], '-r600', '-dpng')
end