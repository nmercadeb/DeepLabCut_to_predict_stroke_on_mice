% Data ----
if windows
    comp_data = readtable(".\Results\dataForStrokeModel.xlsx");
    exp_data  = readtable([path(1:id-1) projectFolder '\' experimentalDataFolder '\dades_model.xlsx']);
else
    comp_data = readtable("./Results/dataForStrokeModel.xlsx");
    exp_data  = readtable([path(1:id-1) projectFolder '/' experimentalDataFolder '/dades_model.xlsx']);
end

comp_data = comp_data(:, [1 7:size(comp_data(1,:), 2)-1]);
comp_data.Infart = comp_data.Infart > 0;

exp_data = exp_data(:, [1 4:size(exp_data(1,:), 2)-1]);
exp_data.Infart = exp_data.Infart > 0;

formula_comp_inicial = ['Infart ~ ' comp_data.Properties.VariableNames{3}];
for i = 4:(size(comp_data,2))
    formula_comp_inicial = [formula_comp_inicial ' + ' comp_data.Properties.VariableNames{i}];
end

formula_exp_inicial = ['Infart ~ ' exp_data.Properties.VariableNames{3}];
for i = 4:(size(exp_data,2))
    formula_exp_inicial = [formula_exp_inicial ' + ' exp_data.Properties.VariableNames{i}];
end

% Computational model ----
if windows
    filePath = [path(1:id-1) projectFolder '\' analysesFolder '\Results\BS_comp.xlsx' ];
else
    filePath = [path(1:id-1) projectFolder '/' analysesFolder '/Results/BS_comp.xlsx' ];
end

modelCreationAndEvalauation(comp_data, formula_comp_inicial,  20, filePath, 200)

% Summary of backward selection results
results = readtable(filePath); 

variables = comp_data.Properties.VariableNames(3:end);
freq = [];

for kk = 1:length(variables)
num = 0;
for jj = 1:size(results,1)
    num = num + sum(any(contains(table2cell(results(jj,15:23)), variables{kk})));
end
freq = [freq num/jj];
end

writecell(variables', filePath, 'Sheet', 'Summary', 'Range', 'A2')
writematrix(freq', filePath, 'Sheet', 'Summary', 'Range', 'B2', 'AutoFitWidth', false)

writematrix(mean(results.Var13-results.Var14), filePath, 'Sheet', 'Summary', 'Range', 'E3', 'AutoFitWidth',false)
writematrix(std(results.Var13-results.Var14), filePath, 'Sheet', 'Summary', 'Range', 'F3', 'AutoFitWidth',false)


% Experimental model ----
if windows
    filePath = [path(1:id-1) projectFolder '\' analysesFolder '\Results\BS_exp.xlsx' ];
else
    filePath = [path(1:id-1) projectFolder '/' analysesFolder '/Results/BS_exp.xlsx' ];
end

modelCreationAndEvalauation(exp_data, formula_exp_inicial,  20, filePath, 200)

% Summary of backward selection results
results = readtable(filePath); 

variables = exp_data.Properties.VariableNames(3:end);
freq = [];

for kk = 1:length(variables)
    num = 0;
    for jj = 1:size(results,1)
        num = num + sum(any(contains(table2cell(results(jj,15:17)), variables{kk})));
    end
    freq = [freq num/jj];
end

writecell(variables', filePath, 'Sheet', 'Summary', 'Range', 'A2')
writematrix(freq', filePath, 'Sheet', 'Summary', 'Range', 'B2', 'AutoFitWidth', false)

writematrix(mean(results.Var13-results.Var14), filePath, 'Sheet', 'Summary', 'Range', 'E3', 'AutoFitWidth',false)
writematrix(std(results.Var13-results.Var14), filePath, 'Sheet', 'Summary', 'Range', 'F3', 'AutoFitWidth',false)
