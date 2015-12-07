function [] = AnalyzeINStability(DataDirs, FileLists, FileType, ContinuousOrNot, InterBoutInterval, InterINInterval, MotifLabels, INLabels, MinNumberSylls, MotifStartSyll, BirdName)

PresentDir = pwd;

% First load up all the files from the respective filelists
for i = 1:length(FileLists),
    cd(DataDirs{i});
    Fid = fopen(FileLists{i}, 'r');
    TempNames = textscan(Fid, '%s', 'DeLimiter', '\n');
    FileNames{i} = TempNames{1};
    fclose(Fid);
    cd(PresentDir);
end

% Now for each of the filelists, load up the labels and onsets and offsets
for i = 1:length(FileLists),
    for j = 1:length(FileNames{i}),
        NoteInfo{i}{j} = load(fullfile(DataDirs{i}, 'ASSLNoteFiles', [FileNames{i}{j}, '.not.mat']));
        % Remove all the '0' labels
        Indices = find(NoteInfo{i}{j}.labels == '0');
        if (~isempty(Indices))
            NoteInfo{i}{j}.labels(Indices) = [];
            NoteInfo{i}{j}.onsets(Indices) = [];
            NoteInfo{i}{j}.offsets(Indices) = [];
        end
        [RawData, Fs] = GetData(fullfile(PresentDir, DataDirs{i}), FileNames{i}{j}, FileType{i}, 0);
        FileLen{i}(j) = length(RawData)*1000/Fs;
    end
end

% Now based on whether the data is continuous or not, identify bouts of
% song
for i = 1:length(FileLists),
    if (ContinuousOrNot(i) == 0)
        for j = 1:length(NoteInfo{i}),
            Bouts{i}(j) = 0;
            BoutIndices{i}{j} = [];
            
            if (isempty(strfind(NoteInfo{i}{j}.labels, MotifLabels)))
                continue;
            end
            
            Gaps = NoteInfo{i}{j}.onsets(2:end) - NoteInfo{i}{j}.offsets(1:end-1);
            LongGaps = find(Gaps >= InterBoutInterval);
            if (isempty(LongGaps))
                if ((NoteInfo{i}{j}.onsets(1) >= InterBoutInterval) && (NoteInfo{i}{j}.offsets(end) <= (FileLen{i}(j) - InterBoutInterval)))
                    Bouts{i}(j) = 1;
                    BoutIndices{i}{j}(end+1,:) = [1 length(NoteInfo{i}{j}.onsets)];
                end
            else
                for k = 1:length(LongGaps),
                    if (k == 1)
                        if (NoteInfo{i}{j}.onsets(1) >= InterBoutInterval)
                            Bouts{i}(j) = 1;
                            BoutIndices{i}{j}(end+1,:) = [1 LongGaps(k)];
                        end
                    else
                        Bouts{i}(j) = 1;
                        BoutIndices{i}{j}(end+1,:) = [(LongGaps(k-1)+1) LongGaps(k)];
                    end
                end
                if (NoteInfo{i}{j}.offsets(end) <= (FileLen{i}(j) - InterBoutInterval))
                    Bouts{i}(j) = 1;
                    BoutIndices{i}{j}(end+1,:) = [(LongGaps(end)+1) length(NoteInfo{i}{j}.onsets)];
                end
            end
        end
    else
        [AllLabels{i}, AllOnsets{i}, AllOffsets{i}] = CombineContinuousDataNoteFiles(DataDirs{i}, FileNames{i}, fullfile(DataDirs{i}, 'ASSLNoteFiles'), FileType{i});
        Gaps = AllOnsets{i}(2:end) - AllOffsets{i}(1:end-1);
        LongGaps = find(Gaps >= InterBoutInterval);
        Bouts{i} = 0;
        BoutIndices{i} = [];
        
        if (isempty(LongGaps))
            if ((AllOnsets{i}(1) >= InterBoutInterval) && (AllOffsets{i}(end) <= (sum(FileLen{i}) - InterBoutInterval)))
                Bouts{i} = 1;
                BoutIndices{i}(end+1,:) = [1 length(AllOnsets{i})];
            end
        else
            for k = 1:length(LongGaps),
                if (k == 1)
                    if (isempty(strfind(AllLabels{i}(1:LongGaps(k)), MotifLabels)))
                        continue;
                    end
                    
                    if (AllOnsets{i}(1) >= InterBoutInterval)
                        Bouts{i} = 1;
                        BoutIndices{i}(end+1,:) = [1 LongGaps(k)];
                    end
                else
                    if (isempty(strfind(AllLabels{i}((LongGaps(k-1) + 1):LongGaps(k)), MotifLabels)))
                        continue;
                    end
                    Bouts{i} = 1;
                    BoutIndices{i}(end+1,:) = [(LongGaps(k-1)+1) LongGaps(k)];
                end
            end
            if (isempty(strfind(AllLabels{i}((LongGaps(end) + 1):end), MotifLabels)))
                continue;
            end
            
            if (AllOffsets{i}(end) <= (sum(FileLen{i}) - InterBoutInterval))
                Bouts{i}{j} = 1;
                BoutIndices{i}{j}(end+1,:) = [(LongGaps(end)+1) length(AllLabels{i})];
            end
        end
    end
end

% Now that bouts have been identified, collate all bouts together for
% calculating transition probabilities
% Basically, add a 'Q' at the beginning of each bout and a 'q' at the end
% of each bout

for i = 1:length(FileLists),
    BoutLabels{i} = [];
    if (ContinuousOrNot(i) == 0)
        for j = 1:length(Bouts{i}),
            if (Bouts{i}(j) == 1)
                for k = 1:size(BoutIndices{i}{j},1),
                    BoutLabels{i} = [BoutLabels{i} 'Q' NoteInfo{i}{j}.labels(BoutIndices{i}{j}(k,1):BoutIndices{i}{j}(k,2)), 'q'];
                end
            end
        end
    else
        for j = 1:size(BoutIndices{i},1),
            BoutLabels{i} = [BoutLabels{i} 'Q' AllLabels{i}(BoutIndices{i}(j,1):BoutIndices{i}(j,2)), 'q'];
        end
    end
end

% Now to calculate transition probabilities and display them as a colour
% graph

for i = 1:length(FileLists),
    UniqueLabels = unique(BoutLabels{i});
    UniqueLabels = mat2cell(UniqueLabels, 1, ones(size(UniqueLabels)));
    for j = 1:length(UniqueLabels),
        if (UniqueLabels{j} == 'q')
            continue;
        end
        Matches = find(BoutLabels{i} == UniqueLabels{j});
        if (length(Matches) < MinNumberSylls)
            continue;
        end
        for k = 1:length(UniqueLabels),
            TransProb{i}(j,k) = length(find(BoutLabels{i}(Matches+1) == UniqueLabels{k}))/length(Matches);
        end
    end
    ActualTransProb{i} = TransProb{i};
    TransProb{i}(find(TransProb{i} < 0.05)) = 0;
    figure;
    imagesc(TransProb{i});
    set(gca, 'XTick', [1:1:length(UniqueLabels)], 'XTickLabel', UniqueLabels);
    set(gca, 'YTick', [1:1:length(UniqueLabels)], 'YTickLabel', UniqueLabels);
    title(DataDirs{i});
    
    ColWidth = {50};
    SyllTransProbFigure{i} = figure('Position', [200 200 (ColWidth{1}*length(UniqueLabels) + 100) (15*(length(UniqueLabels)) + 100)]);
    SyllTransTable = uitable('Parent', SyllTransProbFigure{i}, 'Data', TransProb{i}, 'ColumnName', UniqueLabels, 'RowName', UniqueLabels, 'Position', [20 20 (ColWidth{1}*length(UniqueLabels) + 60) (15*(length(UniqueLabels) - 1) + 60)]); 
    set(SyllTransTable, 'ColumnWidth', ColWidth);
    title(['Syllable transition probabilities: ', DataDirs{i}], 'FontWeight', 'bold', 'FontSize', 12);
    set(gca, 'XTick', []);
end

% Now calculate and plot bout length - Calculate both length of bout in
% terms of number of syllables and in terms of time

for i = 1:length(FileLists),
    BoutLen{i} = [];
    if (ContinuousOrNot(i) == 0)
        for j = 1:length(BoutIndices{i}),
            if (~isempty(BoutIndices{i}{j}))
                for k = 1:size(BoutIndices{i}{j},1),
                    BoutLen{i}(end+1,:) = [(BoutIndices{i}{j}(k,2) - BoutIndices{i}{j}(k,1) + 1) (NoteInfo{i}{j}.offsets(BoutIndices{i}{j}(k,2)) - NoteInfo{i}{j}.onsets(BoutIndices{i}{j}(k,1)))];
                end
            end
        end
    else
        for k = 1:size(BoutIndices{i},1),
            BoutLen{i}(end+1,:) = [(BoutIndices{i}(k,2) - BoutIndices{i}(k,1) + 1) (AllOffsets{i}(BoutIndices{i}(k,2)) - AllOnsets{i}(BoutIndices{i}(k,1)))];
        end
    end
end

% First plot bout length in terms of number of syllables. 
% Keep track of this using a variable that has in the first column the
% number of syllables in a bout and the second column contains information
% about which day it comes from
figure;
set(gcf, 'Position', [427 307 750 400]);

BoutLen_NumSylls = [];
for i = 1:length(FileLists),
    BoutLen_NumSylls = [BoutLen_NumSylls; [BoutLen{i}(:,1) ones(size(BoutLen{i}(:,1)))*i]];
end
set(gcf, 'Color', 'w');
boxplot(BoutLen_NumSylls(:,1), BoutLen_NumSylls(:,2));
set(gca, 'XTick', [1:1:length(FileLists)], 'XTickLabel', DataDirs);
ylabel('# of syllables per bout', 'FontSize', 14);
set(gca, 'FontSize', 14);
title([BirdName, ': # of syllables per bout on different days']);

% Next plot bout length in terms of time. 
% Keep track of this using a variable that has in the first column the
% length of time in a bout and the second column contains information
% about which day it comes from
figure;
set(gcf, 'Position', [427 307 750 400]);

BoutLen_Time = [];
for i = 1:length(FileLists),
    BoutLen_Time = [BoutLen_Time; [BoutLen{i}(:,2) ones(size(BoutLen{i}(:,2)))*i]];
end
boxplot(BoutLen_Time(:,1)/1000, BoutLen_Time(:,2));
set(gcf, 'Color', 'w');
set(gca, 'XTick', [1:1:length(FileLists)], 'XTickLabel', DataDirs);
ylabel('Bout Length (sec)', 'FontSize', 14);
set(gca, 'FontSize', 14);
title([BirdName, ': Bout length (sec) on different days']);

% Now to find the number of intro notes before each first motif syllable on
% different days
% I'm going to consider any sequence of vocalizations with less than 500ms
% between them as a sequence before the first motif syllable. I'll keep
% track of how many of these are INs and the total number of these in the
% first and second column respectively of the variable NumINs. The third
% column in this variable keeps track of whether it is beginning of bout
% (1) or within bout (> 1). This value is actually the correct position of
% the motif within the bout.

for i = 1:length(FileLists),
    NumINs{i} = [];
    if (ContinuousOrNot(i) == 0)
        for j = 1:length(BoutIndices{i}),
            if (~isempty(BoutIndices{i}{j}))
                for k = 1:size(BoutIndices{i}{j},1),
                    FirstMotifSyllIndices = find(NoteInfo{i}{j}.labels(BoutIndices{i}{j}(k,1):BoutIndices{i}{j}(k,2)) == MotifStartSyll);
                    FirstMotifSyllIndices = FirstMotifSyllIndices + BoutIndices{i}{j}(k,1) - 1;
                    
                    for FirstMotifIndex = 1:length(FirstMotifSyllIndices),
                        if (FirstMotifIndex == 1)
                            PotentialIN_Indices = BoutIndices{i}{j}(k,1):1:(FirstMotifSyllIndices(FirstMotifIndex) - 1);
                        else
                            PotentialIN_Indices = (FirstMotifSyllIndices(FirstMotifIndex - 1) + length(MotifLabels)):1:(FirstMotifSyllIndices(FirstMotifIndex) - 1);
                        end
                        
                        Gaps = NoteInfo{i}{j}.onsets(PotentialIN_Indices(2:end)) - NoteInfo{i}{j}.offsets(PotentialIN_Indices(1:end-1));
                        
                        if (isempty(find(Gaps >= InterINInterval)))
                            IN_Indices = PotentialIN_Indices;
                        else
                            LongGaps = find(Gaps >= InterINInterval);
                            IN_Indices = PotentialIN_Indices(LongGaps(end)+1:end);
                        end
                        
                        % Now to find out how many of these are INs
                        INCounter = 0;
                        for IN_Index = length(IN_Indices):-1:1,
                            if (~isempty(find(INLabels == NoteInfo{i}{j}.labels(IN_Indices(IN_Index)))))
                                INCounter = INCounter + 1;
                            else
                                break;
                            end
                        end
                        NumINs{i}(end+1,:) = [length(IN_Indices) INCounter FirstMotifIndex];
                    end
                end
            end
        end
    else
        for j = 1:size(BoutIndices{i},1),
            
            FirstMotifSyllIndices = find(AllLabels{i}(BoutIndices{i}(j,1):BoutIndices{i}(j,2)) == MotifStartSyll);
            FirstMotifSyllIndices = FirstMotifSyllIndices + BoutIndices{i}(j,1) - 1;
            
            for FirstMotifIndex = 1:length(FirstMotifSyllIndices),
                if (FirstMotifIndex == 1)
                    PotentialIN_Indices = BoutIndices{i}(j,1):1:(FirstMotifSyllIndices(FirstMotifIndex) - 1);
                else
                    PotentialIN_Indices = (FirstMotifSyllIndices(FirstMotifIndex - 1) + length(MotifLabels)):1:(FirstMotifSyllIndices(FirstMotifIndex) - 1);
                end
                
                Gaps = AllOnsets{i}(PotentialIN_Indices(2:end)) - AllOffsets{i}(PotentialIN_Indices(1:end-1));

                if (isempty(find(Gaps >= InterINInterval)))
                    IN_Indices = PotentialIN_Indices;
                else
                    LongGaps = find(Gaps >= InterINInterval);
                    IN_Indices = PotentialIN_Indices(LongGaps(end)+1:end);
                end

                % Now to find out how many of these are INs
                INCounter = 0;
                for IN_Index = length(IN_Indices):-1:1,
                    if (~isempty(find(INLabels == AllLabels{i}(IN_Indices(IN_Index)))))
                        INCounter = INCounter + 1;
                    else
                    break;
                    end
                end
                NumINs{i}(end+1,:) = [length(IN_Indices) INCounter FirstMotifIndex];
            end
        end
    end
end

% Now plot the number of INs and number of syllables separately for within
% bouts and for beginning of bouts
figure;
hold on;
% First get for beginning of bouts
for i = 1:length(FileLists),
    BegBoutIndices = find(NumINs{i}(:,3) == 1);
    BoutBeg_NumSyllables(i,:) = [mean(NumINs{i}(BegBoutIndices,1)) std(NumINs{i}(BegBoutIndices,1))/sqrt(length(BegBoutIndices))];
    BoutBeg_NumINs(i,:) = [mean(NumINs{i}(BegBoutIndices,2)) std(NumINs{i}(BegBoutIndices,2))/sqrt(length(BegBoutIndices))];
end

% Now for within bouts
for i = 1:length(FileLists),
    WithinBoutIndices = find(NumINs{i}(:,3) > 1);
    WithinBout_NumSyllables(i,:) = [mean(NumINs{i}(WithinBoutIndices,1)) std(NumINs{i}(WithinBoutIndices,1))/sqrt(length(WithinBoutIndices))];
    WithinBout_NumINs(i,:) = [mean(NumINs{i}(WithinBoutIndices,2)) std(NumINs{i}(WithinBoutIndices,2))/sqrt(length(WithinBoutIndices))];
end

errorbar(BoutBeg_NumINs(:,1), BoutBeg_NumINs(:,2), 'ro-');
errorbar(BoutBeg_NumSyllables(:,1), BoutBeg_NumSyllables(:,2), 'bo-');
errorbar(WithinBout_NumINs(:,1), WithinBout_NumINs(:,2), 'r^--');
errorbar(WithinBout_NumSyllables(:,1), WithinBout_NumSyllables(:,2), 'b^--');

axis tight;
Temp = axis;
Temp(1) = 0.5;
Temp(2) = length(FileLists) + 1.5;
Temp(3) = 0;
Temp(4) = 1.02*Temp(4);
axis(Temp);

set(gcf, 'Position', [325 219 850 400]);
set(gcf, 'Color', 'w');
set(gca, 'XTick', [1:1:length(FileLists)], 'XTickLabel', DataDirs);
ylabel('# of INs/Syllables', 'FontSize', 14);
set(gca, 'FontSize', 14);
title([BirdName, ': IN # and Syll # on different days']);
legend('IN #: begin', 'Syll #: begin', 'IN #: within', 'Syll #: within');

disp('Finished analysis');


