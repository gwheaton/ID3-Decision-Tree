function [classifications] = ClassifyByTree(tree, attributes, instance)
% ClassifyByTree   Classifies data instance by given tree
% args:
%       tree            - tree data structure
%       attributes      - cell array of attribute strings (no CLASS)
%       instance        - data including correct classification (end col.)
% return:
%       classifications     - 2 numbers, first given by tree, 2nd given by
%                             instance's last column
% tree struct:
%       value               - will be the string for the splitting
%                             attribute, or 'true' or 'false' for leaf
%       left                - left pointer to another tree node (left means
%                             the splitting attribute was false)
%       right               - right pointer to another tree node (right
%                             means the splitting attribute was true)

% Store the actual classification
actual = instance(1, length(instance));

% Recursion with 3 cases

% Case 1: Current node is labeled 'true'
% So trivially return the classification as 1
if (strcmp(tree.value, 'true'));
    classifications = [1, actual];
    return
end

% Case 2: Current node is labeled 'false'
% So trivially return the classification as 0
if (strcmp(tree.value, 'false'));
    classifications = [0, actual];
    return
end

% Case 3: Current node is labeled an attribute
% Follow correct branch by looking up index in attributes, and recur
index = find(ismember(attributes,tree.value)==1);
if (instance(1, index)); % attribute is true for this instance
    % Recur down the right side
    classifications = ClassifyByTree(tree.right, attributes, instance); 
else
    % Recur down the left side
    classifications = ClassifyByTree(tree.left, attributes, instance);
end

return
end