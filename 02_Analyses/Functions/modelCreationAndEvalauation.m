function modelCreationAndEvalauation(data, formula_inicial, mouseToTrain, filePath, numIter)
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
yPred_G = [];
yObs_G  = [];

 

for jj = 1:numIter
    [test, train] = splitData(data, mouseToTrain);
    
    if any(data.Infart > 1)
        model = fitlm(train, formula_inicial);
    else
        model = fitglm(train, formula_inicial, 'Distribution', 'binomial');
    end

    writematrix(jj, filePath, 'Sheet', 'Results', "Range", ['A' num2str(jj+3)], 'AutoFitWidth', false)
    writematrix(size(data,2)-2, filePath, 'Sheet', 'Results', "Range", ['M' num2str(jj+3)], 'AutoFitWidth', false)

    model = backwardSelection(model, filePath, jj);

    % Individual:
    yPred_I = [yPred_I; predict(model,test)];
    yObs_I  = [yObs_I; test.Infart];
    
    % Grouped:
    testMice = unique(test.Mouse);
    for jj = 1:length(testMice)
        yPred_G = [yPred_G; mean(model.predict(data(ismember(data.Mouse, testMice(jj)),:)))];
        yObs_G  = [yObs_G; mean(data.Infart(ismember(data.Mouse, testMice(jj))))];
    end
end
writematrix(yObs_I, filePath, 'Sheet', 'Evaluation', "Range", 'A3', 'AutoFitWidth', false)
writematrix(yPred_I, filePath, 'Sheet', 'Evaluation', "Range", 'B3', 'AutoFitWidth', false)
writematrix(yObs_G, filePath, 'Sheet', 'Evaluation', "Range", 'C3', 'AutoFitWidth', false)
writematrix(yPred_G, filePath, 'Sheet', 'Evaluation', "Range", 'D3', 'AutoFitWidth', false)
end