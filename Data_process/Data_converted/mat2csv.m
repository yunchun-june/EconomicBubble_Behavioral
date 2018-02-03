
%this is an example of how to read the data

files = dir('*.mat');
fileNum = length(files);

for i = 1:fileNum
    data = load(files(i).name);
    result = data.result;
    
    for row = 2:length(result)
        event1 = result{row,12};
        event2 = result{row,14};
        
        str1 = '';
        len = size(event1);
        len = len(1);
        for j = 1:len
            str1 = [str1 event1{j,1} '-' event1{j,2} '/'];
        end
        
        str2 = '';
        len = size(event2);
        len = len(1);
        for j = 1:len
            str2 = [str2 event2{j,1} '-' event2{j,2} '/'];
        end
        
        result{row,12} = str1;
        result{row,14} = str2;
    end
    
    fileName = ['./csv/' files(i).name(1:13) '.csv'];
    cell2csv(fileName, result);
end