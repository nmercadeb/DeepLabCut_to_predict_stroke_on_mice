function [test, train] = splitData(data, mouseToTrain)
%
% Input parameters:
%  - data: matlab table containg data for the model
%  - mouseToTrain: number of mice to use for training the model (the rest
%     will be used for evaluation)
% Output: 
%  - train: matlab table with subset of data to train the model
%  - train: matlab table with subset of data to evaluate the model

mice    = unique(data.Mouse);
numMice = length(mice);

testMice = mice(randi(numMice,1,numMice-mouseToTrain));
indTest  = ismember(data.Mouse, testMice);

test  = data(indTest,:);
train = data(~indTest,:);

end