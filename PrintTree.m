function [] = PrintTree(tree, parent)
% Prints the tree structure (preorder traversal)

% Print current node
if (strcmp(tree.value, 'true'));
    fprintf('parent: %s\ttrue\n', parent);
    return
elseif (strcmp(tree.value, 'false'));
    fprintf('parent: %s\tfalse\n', parent);
    return
else
    % Current node an attribute splitter
    fprintf('parent: %s\tattribute: %s\tfalseChild:%s\ttrueChild:%s\n', ...
        parent, tree.value, tree.left.value, tree.right.value);
end

% Recur the left subtree
PrintTree(tree.left, tree.value);

% Recur the right subtree
PrintTree(tree.right, tree.value);

end