ID3-Decision-Tree
=================

A MATLAB implementation of the ID3 decision tree algorithm for EECS349 - Machine Learning

Quick installation:
-Download the files and put into a folder
-Open up MATLAB and at the top hit the 'Browse by folder' button
-Select the folder that contains the MATLAB files you just downloaded
-The 'Current Folder' menu should now show the files (ClassifyByTree.m, etc.)

Now you can use the functions in the command prompt of MATLAB


Use:
decisiontree.m provides the main script for running the ID3 algorithm. You provide it with options as well as an input text file of data.

This input file is tab-delimited. For example, if you wanted to classify the data points with attributes a1, a2, and a3 the input file would be

a1  a2  a3  CLASS
true  false false true
false true  false true
etc.

where each row represents a new data point and the last Boolean is what that point was classified as
