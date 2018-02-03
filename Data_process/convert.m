clc;

colName = cell(1,14);
colName{1} =    'trials';
colName{2} =    'marketCondition';
colName{3} =    'marketDramatic';
colName{4} =    'stockPrice';
colName{5} =    'player1Cash';
colName{6} =    'player1Stock';
colName{7} =    'player1TotalAsset';
colName{8} =    'player2Cash';
colName{9} =    'player2Stock';
colName{10} =   'player2TotalAsset';
colName{11} =   'player1Decision';
colName{12} =   'player1event';
colName{13} =   'player2Decision';
colName{14} =   'player2event';

folders = dir( 'Raw_Data*');
folderNum = length(folders);

merged = 0;
failed = 0;

for index_folder = 1:folderNum
    foldername = folders(index_folder).name;
    cd(foldername);
    
    files = dir('EBG*.mat');
    fileNum = length(files);
    done = zeros(1,fileNum);
    for i = 1:fileNum

        if(done(1,i) == 1)
            %fprintf('This file has been merged.\n');
            continue;
        end

        %=== load data ===%
        filename = files(i).name;
        %fprintf(['This is ' filename '\n']);
        data1 = load(filename);
        %fprintf(['p1ID = ' p1ID '\n']);

        %=== find conterpart ===%
        counterpart = 0;
        for j = 1:fileNum
            if(counterpart ~= 0) break; end
            if(i==j) continue; end
            data2 = load(files(j).name);
            %fprintf(['file' files(j).name ' p1ID = ' data2.result.player1ID '\n']);
            if(strcmp(data2.result.player2ID , data1.result.player1ID))
                counterpart = j;
            end
        end

        if(counterpart == 0)
            fprintf(['No conterpart for file ' filename '\n']);
            failed = failed +1;
            continue;
        end

        assert(strcmp(data1.result.player1ID, data2.result.player2ID));
        done(1,i) = 1;
        done(1,counterpart) = 1;

        %=== move data ===%
        anomoly = 0;
        trial = length(data1.result.result);
        rule = data1.result.rule;
        result = data1.result.result;
        toSave = cell(trial+1,14);
        for col = 1:14
            toSave{1,col} = colName{col};
        end

        for row = 1:trial 
            for col = 1:14
                toSave{row+1,col} = result{row,col};
            end
            if(result{row,4} ~= data2.result.result{row,4})
                anomoly = 1;
                break;
            end
            if(toSave{row+1,3} == 1)toSave{row+1,3} = 'balenced'; end
            if(toSave{row+1,3} == 2)toSave{row+1,3} = 'bubble'; end
            if(toSave{row+1,3} == 3)toSave{row+1,3} = 'burst'; end
        end

        if(anomoly)
            fprintf(['Anomoly in file ' filename ', convert stopped.\n']);
            failed = failed +1;
            continue;
        end

        if(strcmp(rule,'player1'))
            for row = 1:trial
                toSave{row+1,14} = data2.result.result{row,14}; %col 14 = player2 events
            end
        end

        if(strcmp(rule,'player2'))
            for row = 1:trial
                toSave{row+1,12} = data2.result.result{row,12}; %col 12 = player1 events
            end
        end

        prefix = ['../Converted/' foldername(10:length(foldername))];
        index = filename(length(filename)-5);
        saveFilename = [prefix '_' index];
        result = toSave;
        save(saveFilename,'result');
        merged = merged +1;
        %fprintf(['Saved to file ' saveFilename '\n']);
    end

    cd('../')
end

fprintf(['-----------\n']);
fprintf(['Merged: ' num2str(merged) 'Failed: ' num2str(failed) '\n']);
