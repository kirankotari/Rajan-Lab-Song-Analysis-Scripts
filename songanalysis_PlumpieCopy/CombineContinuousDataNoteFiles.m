function [AllLabels, AllOnsets, AllOffsets] = CombineContinuousDataNoteFiles(DirName, Files, NoteFileDir, FileType)

AllLabels = [];
AllOnsets = [];
AllOffsets = [];
CumulativeFileTime = 0;

for i = 1:length(Files),
    [RawData, Fs] = GetData(DirName, Files{i}, FileType, 0);
    NoteInfo{i} = load(fullfile(NoteFileDir, [Files{i}, '.not.mat']));
    if (~isempty(NoteInfo{i}.labels))
        AllLabels = [AllLabels NoteInfo{i}.labels];
        AllOnsets = [AllOnsets(:); (NoteInfo{i}.onsets(:) + CumulativeFileTime)];
        AllOffsets = [AllOffsets(:); (NoteInfo{i}.offsets(:) + CumulativeFileTime)];
    end
    CumulativeFileTime = CumulativeFileTime + (length(RawData)*1000/Fs);
end

% Now delete all labels with '0' as they're just noise
IndicesToDelete = find(AllLabels == '0');
AllLabels(IndicesToDelete) = [];
AllOnsets(IndicesToDelete) = [];
AllOffsets(IndicesToDelete) = [];

% Now fix all consecutive capital letters as they're the same syllable
% split over two files
ConsecutiveCaps = regexp(AllLabels, '[A-Z]');
SyllsToMerge = [];
for i = 1:length(ConsecutiveCaps)-1,
    if (ConsecutiveCaps(i+1) == (ConsecutiveCaps(i) + 1))
        if (AllLabels(ConsecutiveCaps(i)) == AllLabels(ConsecutiveCaps(i+1)))
            SyllsToMerge(end+1) = ConsecutiveCaps(i);
        end
    end
end

AllLabels(SyllsToMerge) = lower(AllLabels(SyllsToMerge));
AllLabels(SyllsToMerge+1) = [];
AllOnsets(SyllsToMerge+1) = [];
AllOffsets(SyllsToMerge) = [];