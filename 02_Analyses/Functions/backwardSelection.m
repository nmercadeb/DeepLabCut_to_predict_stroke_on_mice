function model = backwardSelection(model, filePath, currentIter)
%
% Input parameters:
%  - model: initial model to start the backward feature selection
%  - filePath: path to the xlsx file were results are stored
%  - currentIter: current iteration (writing excel file purposes)
% Output: 
%  - model: final model after backward selection 

abcd = {'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L'};
    for k = 1:40
        [val, ind] = max(model.Coefficients.pValue(2:end));
        modelVars = model.VariableNames(model.VariableInfo.InModel);
        if val <= 0.05
             writematrix(k-1, filePath, 'Sheet', 'Results', "Range", ['N' num2str(currentIter+3)], 'AutoFitWidth', false)
             writecell(model.VariableNames(model.VariableInfo.InModel)', filePath, 'Sheet', 'Results', 'Range', ['O' num2str(currentIter+3)])
             break
        end
        if length(modelVars) == 1
            break
        end
        model= removeTerms(model, modelVars{ind});
        writematrix(modelVars{ind}, filePath, 'Sheet', 'Results', "Range", [abcd{k} num2str(currentIter+3)])
    end
end