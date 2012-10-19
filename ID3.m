function [tree] = ID3(examples, attributes, activeAttributes)
% ID3   Runs the ID3 algorithm on the matrix of examples and attributes
% args:
%       examples            - matrix of 1s and 0s for trues and falses, the
%                             last value in each row being the value of the
%                             classifying attribute
%       attributes          - cell array of attribute strings (no CLASS)
%       activeAttributes    - vector of 1s and 0s, 1 if corresponding attr.
%                             active (no CLASS)
% return:
%       tree                - the root node of a decision tree
% tree struct:
%       value               - will be the string for the splitting
%                             attribute, or 'true' or 'false' for leaf
%       left                - left pointer to another tree node (left means
%                             the splitting attribute was false)
%       right               - right pointer to another tree node (right
%                             means the splitting attribute was true)

if (isempty(examples));
    error('Must provide examples');
end

% Constants
numberAttributes = length(activeAttributes);
numberExamples = length(examples(:,1));

% Create the tree node
tree = struct('value', 'null', 'left', 'null', 'right', 'null');

% If last value of all rows in examples is 1, return tree labeled 'true'
lastColumnSum = sum(examples(:, numberAttributes + 1));
if (lastColumnSum == numberExamples);
    tree.value = 'true';
    return
end
% If last value of all rows in examples is 0, return tree labeled 'false'
if (lastColumnSum == 0);
    tree.value = 'false';
    return
end
% If activeAttributes is empty, then return tree with label as most common
% value
if (sum(activeAttributes) == 0);
    if (lastColumnSum >= numberExamples / 2);
        tree.value = 'true';
    else
        tree.value = 'false';
    end
    return
end

% Find the current entropy
p1 = lastColumnSum / numberExamples;
if (p1 == 0);
    p1_eq = 0;
else
    p1_eq = -1*p1*log2(p1);
end
p0 = (numberExamples - lastColumnSum) / numberExamples;
if (p0 == 0);
    p0_eq = 0;
else
    p0_eq = -1*p0*log2(p0);
end
currentEntropy = p1_eq + p0_eq;
% Find the attribute that maximizes information gain
gains = -1*ones(1,numberAttributes); %-1 if inactive, gains for all else 
% Loop through attributes updating gains, making sure they are still active
for i=1:numberAttributes;
    if (activeAttributes(i)) % this one is still active, update its gain
        s0 = 0; s0_and_true = 0;
        s1 = 0; s1_and_true = 0;
        for j=1:numberExamples;
            if (examples(j,i)); % this instance has splitting attr. true
                s1 = s1 + 1;
                if (examples(j, numberAttributes + 1)); %target attr is true
                    s1_and_true = s1_and_true + 1;
                end
            else
                s0 = s0 + 1;
                if (examples(j, numberAttributes + 1)); %target attr is true
                    s0_and_true = s0_and_true + 1;
                end
            end
        end
        
        % Entropy for S(v=1)
        if (~s1);
            p1 = 0;
        else
            p1 = (s1_and_true / s1); 
        end
        if (p1 == 0);
            p1_eq = 0;
        else
            p1_eq = -1*(p1)*log2(p1);
        end
        if (~s1);
            p0 = 0;
        else
            p0 = ((s1 - s1_and_true) / s1);
        end
        if (p0 == 0);
            p0_eq = 0;
        else
            p0_eq = -1*(p0)*log2(p0);
        end
        entropy_s1 = p1_eq + p0_eq;

        % Entropy for S(v=0)
        if (~s0);
            p1 = 0;
        else
            p1 = (s0_and_true / s0); 
        end
        if (p1 == 0);
            p1_eq = 0;
        else
            p1_eq = -1*(p1)*log2(p1);
        end
        if (~s0);
            p0 = 0;
        else
            p0 = ((s0 - s0_and_true) / s0);
        end
        if (p0 == 0);
            p0_eq = 0;
        else
            p0_eq = -1*(p0)*log2(p0);
        end
        entropy_s0 = p1_eq + p0_eq;
        
        gains(i) = currentEntropy - ((s1/numberExamples)*entropy_s1) - ((s0/numberExamples)*entropy_s0);
    end
end

% Pick the attribute that maximizes gains
[~, bestAttribute] = max(gains);
% Set tree.value to bestAttribute's relevant string
tree.value = attributes{bestAttribute};
% Remove splitting attribute from activeAttributes
activeAttributes(bestAttribute) = 0;

% Initialize and create the new example matrices
examples_0 = []; examples_0_index = 1;
examples_1 = []; examples_1_index = 1;
for i=1:numberExamples;
    if (examples(i, bestAttribute)); % this instance has it as 1/true
        examples_1(examples_1_index, :) = examples(i, :); % copy over
        examples_1_index = examples_1_index + 1;
    else
        examples_0(examples_0_index, :) = examples(i, :);
        examples_0_index = examples_0_index + 1;
    end
end

% For both values of the splitting attribute
% For value = false or 0, corresponds to left branch
% If examples_0 is empty, add leaf node to the left with relevant label
if (isempty(examples_0));
    leaf = struct('value', 'null', 'left', 'null', 'right', 'null');
    if (lastColumnSum >= numberExamples / 2); % for matrix examples
        leaf.value = 'true';
    else
        leaf.value = 'false';
    end
    tree.left = leaf;
else
    % Here is were we can recur
    tree.left = ID3(examples_0, attributes, activeAttributes);
end
% For value = true or 1, corresponds to right branch
% If examples_1 is empty, add leaf node to the right with relevant label
if (isempty(examples_1));
    leaf = struct('value', 'null', 'left', 'null', 'right', 'null');
    if (lastColumnSum >= numberExamples / 2); % for matrix examples
        leaf.value = 'true';
    else
        leaf.value = 'false';
    end
    tree.right = leaf;
else
    % Here is were we can recur
    tree.right = ID3(examples_1, attributes, activeAttributes);
end

% Now we can return tree
return
end