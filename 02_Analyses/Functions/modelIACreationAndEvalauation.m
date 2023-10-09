function modelIACreationAndEvalauation(data, formula_inicial, mouseToTrain, filePath, numIter)
%
% Input parameters:
%  - data: matlab table containg data for the model
%  - formula_inicial: starting formula for the backward selection 
%  - mouseToTrain: number of mice to use for training the model (the rest
%     will be used for evaluation)
%  - filePath: path to the xlsx file were results are stored
%  - numIter: number of iterations
%
% * Results are stored in the excel file

yPred_I = [];
yObs_I  = [];
yClass_I  = [];
yClass_G = [];
yPred_G = [];
yObs_G  = [];


data.InfartGroups(data.Infart == 0) =  0;
data.InfartGroups(data.Infart > 0 & data.Infart <= 28) = 1;
data.InfartGroups(data.Infart > 28) = 2;



for jj = 1:numIter
    [test, train] = splitData(data, mouseToTrain);

    model = fitcdiscr(train, formula_inicial);


    %     writematrix(jj, filePath, 'Sheet', 'Results', "Range", ['A' num2str(jj+3)], 'AutoFitWidth', false)
    %     writematrix(size(data,2)-2, filePath, 'Sheet', 'Results', "Range", ['M' num2str(jj+3)], 'AutoFitWidth', false)

    %     model = backwardSelection(model, filePath, jj);

    % Individual:
    yPred_I = [yPred_I; predict(model,test)];
    yObs_I  = [yObs_I; test.Infart];
    yClass_I = [yClass_I; test.InfartGroups];

    % Grouped:
    testMice = unique(test.Mouse);
    for jj = 1:length(testMice)
        yPred_G = [yPred_G; round(median(model.predict(data(ismember(data.Mouse, testMice(jj)),:))))];
        yObs_G  = [yObs_G; median(data.Infart(ismember(data.Mouse, testMice(jj))))];
        yClass_G = [yClass_G; median(data.InfartGroups(ismember(data.Mouse, testMice(jj))))];
    end
end
writematrix(yObs_I, filePath, 'Sheet', 'Evaluation', "Range", 'A3', 'AutoFitWidth', false)
writematrix(yClass_I, filePath, 'Sheet', 'Evaluation', "Range", 'B3', 'AutoFitWidth', false)
writematrix(yPred_I, filePath, 'Sheet', 'Evaluation', "Range", 'C3', 'AutoFitWidth', false)
writematrix(yObs_G, filePath, 'Sheet', 'Evaluation', "Range", 'D3', 'AutoFitWidth', false)
writematrix(yClass_G, filePath, 'Sheet', 'Evaluation', "Range", 'E3', 'AutoFitWidth', false)
writematrix(yPred_G, filePath, 'Sheet', 'Evaluation', "Range", 'F3', 'AutoFitWidth', false)
end