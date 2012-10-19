% George Wheaton
% EECS 349
% Homework 1 Problem 7
% October 7, 2012

% ID3 Decision Tree Algorithm

function[] = decisiontree(inputFileName, trainingSetSize, numberOfTrials,...
                          verbose)
% DECISIONTREE Create a decision tree by following the ID3 algorithm
% args:
%   inputFileName       - the fully specified path to input file
%   trainingSetSize     - integer specifying number of examples from input
%                         used to train the dataset
%   numberOfTrials      - integer specifying how many times decision tree
%                         will be built from a randomly selected subset
%                         of the training examples
%   verbose             - string that must be eiher '1' or '0', if '1'
%                         output includes training and test sets, else
%                         it will only contain description of tree and
%                         results for the trials

% Read in the specified text file contain the examples
fid = fopen(inputFileName, 'rt');
dataInput = textscan(fid, '%s');
% Close the file
fclose(fid);

% Reformat the data into attribute array and data matrix of 1s and 0s for
% true or false
i = 1;
% First store the attributes into a cell array
while (~strcmp(dataInput{1}{i}, 'CLASS'));
    i = i + 1;
end
attributes = cell(1,i);
for j=1:i;
    attributes{j} = dataInput{1}{j};
end

% NOTE: The classification will be the final attribute in the data rows
% below
numAttributes = i;
numInstances = (length(dataInput{1}) - numAttributes) / numAttributes;
% Then store the data into matrix
data = zeros(numInstances, numAttributes);
i = i + 1;
for j=1:numInstances
    for k=1:numAttributes
        data(j, k) = strcmp(dataInput{1}{i}, 'true');
        i = i + 1;
    end
end

% Here is where the trials start
for i=1:numberOfTrials;
    
    % Print the trial number
    fprintf('TRIAL NUMBER: %d\n\n', i);
    
    % Split data into training and testing sets randomly
    % Use randsample to get a vector of row numbers for the training set
    rows = sort(randsample(numInstances, trainingSetSize));
    % Initialize two new matrices, training set and test set
    trainingSet = zeros(trainingSetSize, numAttributes);
    testingSetSize = (numInstances - trainingSetSize);
    testingSet = zeros(testingSetSize, numAttributes);
    % Loop through data matrix, copying relevant rows to each matrix
    training_index = 1;
    testing_index = 1;
    for data_index=1:numInstances;
        if (rows(training_index) == data_index);
            trainingSet(training_index, :) = data(data_index, :);
            if (training_index < trainingSetSize);
                training_index = training_index + 1;
            end
        else
            testingSet(testing_index, :) = data(data_index, :);
            if (testing_index < testingSetSize);
                testing_index = testing_index + 1;
            end
        end
    end
    
    % If verbose, print out training set
    if (verbose);
        for ii=1:numAttributes;
            fprintf('%s\t', attributes{ii});
        end
        fprintf('\n');
        for ii=1:trainingSetSize;
            for jj=1:numAttributes;
                if (trainingSet(ii, jj));
                    fprintf('%s\t', 'true');
                else
                    fprintf('%s\t', 'false');
                end
            end
            fprintf('\n');
        end
    end
    
    % Estimate the expected prior probability of TRUE and FALSE based on
    % training set
    if (sum(trainingSet(:, numAttributes)) >= trainingSetSize);
        expectedPrior = 'true';
    else
        expectedPrior = 'false';
    end
    
    % Construct a decision tree on the training set using the ID3 algorithm
    activeAttributes = ones(1, length(attributes) - 1);
    new_attributes = attributes(1:length(attributes)-1);
    tree = ID3(trainingSet, attributes, activeAttributes);
    
    % Print out the tree
    fprintf('DECISION TREE STRUCTURE:\n');
    PrintTree(tree, 'root');
    
    % Run tree and expected prior against testing set, recording
    % classifications
    % The second column is for actual classification, first for calculated
    ID3_Classifications = zeros(testingSetSize,2);
    ExpectedPrior_Classifications = zeros(testingSetSize,2);
    ID3_numCorrect = 0; ExpectedPrior_numCorrect = 0;
    for k=1:testingSetSize; %over the testing set
        % Call a recursive function to follow the tree nodes and classify
        ID3_Classifications(k,:) = ...
            ClassifyByTree(tree, new_attributes, testingSet(k,:));
        
        ExpectedPrior_Classifications(k, 2) = testingSet(k,numAttributes);
        if (expectedPrior);
            ExpectedPrior_Classifications(k, 1) = 1;
        else
            ExpectedPrior_Classifications(k, 0) = 0;
        end
        
        if (ID3_Classifications(k,1) == ID3_Classifications(k, 2)); %correct
            ID3_numCorrect = ID3_numCorrect + 1;
        end
        if (ExpectedPrior_Classifications(k,1) == ExpectedPrior_Classifications(k,2));
            ExpectedPrior_numCorrect = ExpectedPrior_numCorrect + 1;
        end     
    end
    
    % If verbose, print the testing data with final two columns ID3 Class
    % and Prior Class
    if (verbose);
        for ii=1:numAttributes;
            fprintf('%s\t', attributes{ii});
        end
        fprintf('%s\t%s\t', 'ID3 Class', 'Prior Class');
        fprintf('\n');
        for ii=1:testingSetSize;
            for jj=1:numAttributes;
                if (testingSet(ii, jj));
                    fprintf('%s\t', 'true');
                else
                    fprintf('%s\t', 'false');
                end
            end
            if (ID3_Classifications(ii,1));
                fprintf('%s\t', 'true');
            else
                fprintf('%s\t', 'false');
            end
            if (ExpectedPrior_Classifications(ii,1));
                fprintf('%s\t', 'true');
            else
                fprintf('%s\t', 'false');
            end
            fprintf('\n');
        end
    end
    
    % Calculate the proportions correct and print out
    if (testingSetSize);
        ID3_Percentage = round(100 * ID3_numCorrect / testingSetSize);
        ExpectedPrior_Percentage = round(100 * ExpectedPrior_numCorrect / testingSetSize);
    else
        ID3_Percentage = 0;
        ExpectedPrior_Percentage = 0;
    end
    ID3_Percentages(i) = ID3_Percentage;
    ExpectedPrior_Percentages(i) = ExpectedPrior_Percentage;
    
    fprintf('\tPercent of test cases correctly classified by an ID3 decision tree = %d\n' ...
        , ID3_Percentage);
    fprintf('\tPercent of test cases correctly classified by using prior probabilities from the training set = %d\n\n' ...
        , ExpectedPrior_Percentage);
end
 
 meanID3 = round(mean(ID3_Percentages));
 meanPrior = round(mean(ExpectedPrior_Percentages));
 
 % Print out remaining details
 fprintf('example file used = %s\n', inputFileName);
 fprintf('number of trials = %d\n', numberOfTrials);
 fprintf('training set size for each trial = %d\n', trainingSetSize);
 fprintf('testing set size for each trial = %d\n', testingSetSize);
 fprintf('mean performance (percentage correct) of decision tree over all trials = %d\n', meanID3);
 fprintf('mean performance (percentage correct) of prior probability from training set = %d\n\n', meanPrior);
end