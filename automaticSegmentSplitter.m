% Save a significant amount of time whenever we need to pull data from
% Tobii Studio. Instead of taking multiple days to segment subject data in
% Tobii Studio, we can just export all subject data with a single segment,
% then run this large file through tsvFileSplitter.py, followed by this
% script. Process goes from taking multiple days to about an hour. 

clear
thePath = 'C:\Users\Todd\Desktop\SplitFiles'; % where the outputs of tsvFileSplitter.py are located
cd(thePath)
outputPath = 'C:\Users\Todd\Desktop\Segmented2'; % where you want your output files
mainFolder = dir;
listOfSubjectFolders = {mainFolder(3:end).name}; % first 2 files in directory are '.' and '..', so we just skip them and start at 3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

segmentNames={'DB1' 'DB2' 'DB3' 'DB4' 'DB5' 'DB6' 'DB7' 'DB8' 'DB9' 'DB10' 'DB11' 'JAmonkey' 'JAmoose' 'JArooster' 'JApenguin' 'sandwich1' 'sandwich2' 'MTmonkey' 'MTmoose' 'MTrooster' 'MTpenguin'};
numberOfSujbects=size(listOfSubjectFolders,2);
sampleRate = 120;

%% Initialize the time points for each condition 

DB1 = floor([0.098, 5.527]*sampleRate);
Sandwich1 = floor([5.670, 46.955]*sampleRate);
DB2 = floor([48.813, 53.813]*sampleRate);
JA_Moose = floor([53.955, 61.955]*sampleRate);
DB3 = floor([62.670, 67.098]*sampleRate);
JA_Rooster = floor([67.241, 74.813]*sampleRate);
DB4 = floor([75.241, 79.385]*sampleRate);
JA_Monkey = floor([79.527, 85.527]*sampleRate);
DB5 = floor([86.955, 91.098]*sampleRate);
JA_Penguin = floor([92.098, 99.813]*sampleRate);
DB6 = floor([100.527, 106.384]*sampleRate);
Sandwich2 = floor([106.955, 124.527]*sampleRate);
DB7 = floor([126.527, 134.527]*sampleRate);
MT_Monkey = floor([136.098, 141.098]*sampleRate);
DB8 = floor([141.384, 145.527]*sampleRate);
MT_Penguin = floor([145.670, 152.098]*sampleRate);
DB9 = floor([152.384, 156.670]*sampleRate);
MT_Rooster = floor([157.813, 163.670]*sampleRate);
DB10 = floor([164.098, 168.527]*sampleRate);
MT_Moose = floor([169.527, 176.098]*sampleRate);
DB11 = floor([176.241, 180.813]*sampleRate);

%% 
conditions = [{DB1}, {Sandwich1}, {DB2}, {JA_Moose}, {DB3}, {JA_Rooster}, {DB4}, {JA_Monkey}, {DB5}, {JA_Penguin}, {DB6}, {Sandwich2}, {DB7}, {MT_Monkey}, {DB8}, {MT_Penguin}, {DB9}, {MT_Rooster}, {DB10}, {MT_Moose}, {DB11}];

rowsToRemove = 0; % rowsToRemove will be added to the data to determine which rows should be removed at the end
for i = 1:(size(conditions,2)-1)
    rowsToRemove = [rowsToRemove, conditions{i}(2):conditions{i+1}(1)]; % remove the rows between conditions
end

rowsToRemove = [1:conditions{1}(1), rowsToRemove]; % remove the first few rows before the DB1 condition begins 

for folderNumber=1:numberOfSujbects-2
    cd(thePath)
    varname = listOfSubjectFolders{folderNumber}(1:9); 
    filename=[ varname '.xlsx']
    [num, txt, raw]=xlsread(filename);
    headers = raw(1,:);
    raw = raw(2:end,:); % remove first column from the raw variable, it was unncessary from Tobii Studio
    totalNumberOfRows = size(num,1);
    rowsToRemove = [rowsToRemove, conditions{end}(2):totalNumberOfRows]; % remove the rows after the last segment ends
    for i = 1:size(conditions,2)
        raw(conditions{i}(1):conditions{i}(2), 17) = {num2str(i)};
    end
    
    for rowNumber = 1:totalNumberOfRows
        if any(ismember(rowsToRemove, rowNumber))
            removeColumn{rowNumber, 1} = 1;
        else 
            removeColumn{rowNumber, 1} = 0;
        end
    end
    
    raw = [raw, removeColumn]; % add the removeColumn column to the raw rest of the spreadsheet
    
    test = raw(find([raw{:,96}] == 0), :); % leave only the rows during the conditions
    test = test(:, 1:95);
    raw = [headers; test];
    raw = raw(:,2:end);
    system('taskkill /F /IM EXCEL.EXE'); % MATLAB opens Excel during xlsread, this makes sure that Excel closes before trying to use xlswrite
    outputFileName = [varname 'a.xls'];
    cd(outputPath)
    xlswrite(outputFileName,raw)
    clear removeColumn
end