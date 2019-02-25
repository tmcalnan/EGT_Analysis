% EGT Analysis script for the Sandwich Lady experiment
% Determines the average look duration for each condition type (DB, MT)

close all
clear
thePath = 'C:\Users\tmc54\Documents\EyeTracking\T1';
cd(thePath)
mainFolder = dir;
listOfSubjectFolders = {mainFolder(3:end).name}; % first 2 files in directory are '.' and '..', so we just skip them and start at 3
sampleRate = 120; 
toleranceThreshold = 24; % how many samples we allow before calling something a distraction

[engagementIndexMatrix, totalAttentionMatrixSeconds, totalAttentionMatrix, endDistraction, numberOfAttentionBlocks] = deal(zeros(size(listOfSubjectFolders,2), 21)); % preallocating

%% 
for m = 1:size(listOfSubjectFolders,2) % go through the subjects
    subjectName = listOfSubjectFolders{m};
    cd(thePath)
    cd(subjectName)
    fileName = [subjectName '_EGT_Analysis.mat'];
    datName = ['dat_' subjectName];
    if exist(fileName, 'file')
        fileName = load(fileName, datName); 
        listOfSegmentNames = fieldnames(fileName.(datName)); 
        for n = [1:11, 18:21] % all segments but the sandwich and JA conditions
            condition = listOfSegmentNames{n};
            dat = fileName.(['dat_' subjectName]).(condition); 
            gazeMedia = dat.gazeonmedia;
            noNANs = find(~isnan(gazeMedia(:,1)));
            nans = find(isnan(gazeMedia(:,1)));
            ROIactress = dat.ROImouth + dat.ROIeyes +dat.ROIbody + dat.ROIhands; 
            ROItoys = dat.ROIpenguin + dat.ROIrooster +dat.ROImoose + dat.ROImonkey; 
            ROIall = ROIactress+ROItoys;
            
            %% Find disengagement areas
            disengage = zeros(size(noNANs,1)); % preallocating
            for l = 1:size(noNANs,1)-1
                if noNANs(l+1) - noNANs(l) > toleranceThreshold % allow up to 24 sample gap
                    disengage(l) = noNANs(l) + 1;
                end
            end
            if size(noNANs,1) > 0 
                if noNANs(end)+toleranceThreshold < size(gazeMedia,1) % allow up to the 24 sample gap at the end
                    disengage(size(disengage,2)) = noNANs(end); % In case they don't finish the segment looking at the media
                    endDistraction(m,n) = 1; % to use to find the number of attention blocks
                end
            end
            disengage(disengage == 0) = []; % Get rid of all of the 0s so we just see where the disengagement points were
            
            %% Find out how many blocks of sustained attention there were 
            if ~isempty(noNANs)
                numberOfAttentionBlocks(m,n) = size(disengage,2)+1; % fencepost
            else
                numberOfAttentionBlocks(m,n) = 0; % account for if the subject did not look for even a single sample
            end
            if endDistraction(m,n) == 1 % account for it the block ends with a distractor. The fencepost is the end of the block
                numberOfAttentionBlocks(m,n) = numberOfAttentionBlocks(m,n)-1;
            end
            
            %% Calculate total attention, including the NANs within the tolerance threshold
            if size(disengage,2) > 0
                if endDistraction(m,n) == 0
                   disengage(size(disengage,2)+1) = size(gazeMedia,1); % add in a distraction at the end of the block to use in calculating total amount of attention
                end
                start = zeros(size(disengage)); % preallocating
                finish = zeros(size(disengage)); % preallocating
                start(1) = noNANs(1);
                finish(1) = disengage(1);
                for a = 2:size(disengage,2)
                    start(a) = noNANs(find(noNANs>disengage(a-1), 1 )); % find the first non-NAN after they disengage
                    finish(a) = disengage(a);
                end
                totalAttentionMatrix(m,n) = sum(finish-start)+1; 
            elseif size(disengage,2) == 0 && ~isempty(noNANs) % if they never look away enough for a distraction
                totalAttentionMatrix(m,n) = size(gazeMedia,1)-noNANs(1)+1; % this accounts for any ending NANs compared to noNANs(end)-noNANs(1)+1
            end
            totalAttentionMatrixSeconds(m,n) = totalAttentionMatrix(m,n)/sampleRate; % convert from samples to seconds
        end
    end
end

%% Calculate engagement index
meanAttentionBlocksSocial = mean(numberOfAttentionBlocks(:,1:11),2);
meanAttentionBlocksToys = mean(numberOfAttentionBlocks(:,18:21),2);
meanTotalAttentionSocial = mean(totalAttentionMatrixSeconds(:,1:11),2);
meanTotalAttentionToys = mean(totalAttentionMatrixSeconds(:,18:21),2);

eiSocial = meanTotalAttentionSocial./meanAttentionBlocksSocial;
eiToys = meanTotalAttentionToys./meanAttentionBlocksToys;