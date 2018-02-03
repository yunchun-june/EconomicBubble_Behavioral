
%this is an example of how to read the data

files = dir('*.mat');
fileNum = length(files);

file = load(files(1).name);
data = file.result; % this is a cell array containing data, columns names are specified in the first row.
