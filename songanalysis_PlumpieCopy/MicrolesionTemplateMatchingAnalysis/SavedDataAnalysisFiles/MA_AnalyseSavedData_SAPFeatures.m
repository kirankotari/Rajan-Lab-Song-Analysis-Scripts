function [SyllGapStats] = MA_AnalyseSavedData_SAPFeatures(Parameters, TitleString, varargin)

if (nargin > 2)
    BirdIndices = varargin{1};
    PlotNum = varargin{2};
else
    BirdIndices = 1:1:length(Parameters);
end

OutputDir = '/home/raghav/HVC_MicrolesionDataFigures/PaperFigures/';

PrePostDays = [1 2; 2 3; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 2 5; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2];

Parameters = Parameters(BirdIndices);
PrePostDays = PrePostDays(BirdIndices, :);

Params.NoofBins = 50;
Params.DurEdges = linspace(-2.5, -0.3, Params.NoofBins);
min_int = 7;
min_dur = 7;
                    
for ParameterNo = 1:length(Parameters),
    fprintf('%s >>', Parameters(ParameterNo).BirdName);
    NoteFileDir = [OutputDir, filesep, Parameters(ParameterNo).BirdName, '.NoteFiles', filesep];
    SAPFeatFileDir = [OutputDir, filesep, Parameters(ParameterNo).BirdName, '.SAPFeatFiles', filesep];
    
    if (~exist(NoteFileDir, 'dir'))
        mkdir(NoteFileDir);
    end
    
    if (~exist(SAPFeatFileDir, 'dir'))
        mkdir(SAPFeatFileDir);
    end
    
    for i = 1:Parameters(ParameterNo).NoPreDays,
        fprintf(' Pre Day %i >>', i);
        fprintf(' Dir >>');
        
        DirSyllFeats = [];
        
        BoutIndex = 1;
        
        if (exist('PlotNum', 'var'))
            BoutsToPlot = randperm(length(cell2mat(Parameters(ParameterNo).PreUnDirBoutLens{i})));
            BoutsToPlot = BoutsToPlot(1:min([length(BoutsToPlot) PlotNum]));
        end
        
        for j = 1:length(Parameters(ParameterNo).PreDirBoutLens{i}),
            [RawData, Fs] = ASSLGetRawData(Parameters(ParameterNo).PreDataDir{i}, Parameters(ParameterNo).PreDirSongFileNames{i}{j}, Parameters(ParameterNo).FileType, 0);
            for k = 1:length(Parameters(ParameterNo).PreDirBoutLens{i}{j}),
                SongBout = RawData(ceil(Parameters(ParameterNo).PreDirBoutOnsets{i}{j}(k)*Fs/1000):floor(Parameters(ParameterNo).PreDirBoutOffsets{i}{j}(k)*Fs/1000));
                
                NoteFile = [NoteFileDir, Parameters(ParameterNo).PreDirSongFileNames{i}{j}, '.Bout', num2str(k), '.not.mat'];
                if (exist(NoteFile, 'file'))
                    Temp = load(NoteFile);
                    Onsets = Temp.onsets;
                    Offsets = Temp.offsets;
                else
                    BoutOnset = Parameters(ParameterNo).PreDirBoutOnsets{i}{j}(k);
                    BoutOffset = Parameters(ParameterNo).PreDirBoutOffsets{i}{j}(k);
                    [Onsets, Offsets] = MA_AnalyseSavedData_SegmentFilesAronovFee(SongBout, Fs, min_int, min_dur, NoteFile, BoutOnset, BoutOffset);
                end
        
                if (exist('PlotNum', 'var'))
                    if (~isempty(find(BoutsToPlot == BoutIndex)))
                        PlotSpectrogram_SongVar(SongBout, Fs);
                        for OnNo = 1:length(Onsets),
                            plot([Onsets(OnNo) Onsets(OnNo) Offsets(OnNo) Offsets(OnNo)]/1000, [300 8000 8000 300], 'b', 'LineWidth', 2);
                        end
                    end
                end
                
                SAPFeatureFile = [SAPFeatFileDir, Parameters(ParameterNo).PreDirSongFileNames{i}{j}, '.Bout', num2str(k), '.SAPFeats.mat'];
                if (exist(SAPFeatureFile, 'file'))
                    Temp = load(SAPFeatureFile);
                    Feats = Temp.Feats;
                    FeatureNames = Temp.Feats;
                    FeatureLabels = Temp.FeatureLabels;
                else
                    [Feats, RawFeats] = ASSLCalculateSAPFeatsWithOnsets(SongBout, (1:1:length(SongBout))/Fs, Fs, Onsets/1000, Offsets/1000);
                    [Feats, FeatureNames, FeatureLabels] = MA_ReAssignSAPFeats(Feats, SAPFeatureFile);
                end
                DirSyllFeats = [DirSyllFeats; Feats];
                
                BoutIndex = BoutIndex + 1;
            end
        end

        fprintf(' Undir >>');
        
        UnDirSyllFeats = [];
        BoutIndex = 1;
        if (exist('PlotNum', 'var'))
            BoutsToPlot = randperm(length(cell2mat(Parameters(ParameterNo).PreUnDirBoutLens{i})));
            BoutsToPlot = BoutsToPlot(1:min([length(BoutsToPlot) PlotNum]));
        end
        
        for j = 1:length(Parameters(ParameterNo).PreUnDirBoutLens{i}),
            [RawData, Fs] = ASSLGetRawData(Parameters(ParameterNo).PreDataDir{i}, Parameters(ParameterNo).PreUnDirSongFileNames{i}{j}, Parameters(ParameterNo).FileType, 0);
            for k = 1:length(Parameters(ParameterNo).PreUnDirBoutLens{i}{j}),
                SongBout = RawData(ceil(Parameters(ParameterNo).PreUnDirBoutOnsets{i}{j}(k)*Fs/1000):floor(Parameters(ParameterNo).PreUnDirBoutOffsets{i}{j}(k)*Fs/1000));
                
                NoteFile = [NoteFileDir, Parameters(ParameterNo).PreUnDirSongFileNames{i}{j}, '.Bout', num2str(k), '.not.mat'];
                if (exist(NoteFile, 'file'))
                    Temp = load(NoteFile);
                    Onsets = Temp.onsets;
                    Offsets = Temp.offsets;
                else
                    BoutOnset = Parameters(ParameterNo).PreUnDirBoutOnsets{i}{j}(k);
                    BoutOffset = Parameters(ParameterNo).PreUnDirBoutOffsets{i}{j}(k);
                    [Onsets, Offsets] = MA_AnalyseSavedData_SegmentFilesAronovFee(SongBout, Fs, min_int, min_dur, NoteFile, BoutOnset, BoutOffset);
                end

                if (exist('PlotNum', 'var'))
                    if (~isempty(find(BoutsToPlot == BoutIndex)))
                        PlotSpectrogram_SongVar(SongBout, Fs);
                        for OnNo = 1:length(Onsets),
                            plot([Onsets(OnNo) Onsets(OnNo) Offsets(OnNo) Offsets(OnNo)]/1000, [300 8000 8000 300], 'b', 'LineWidth', 2);
                        end
                    end
                end
                
                SAPFeatureFile = [SAPFeatFileDir, Parameters(ParameterNo).PreUnDirSongFileNames{i}{j}, '.Bout', num2str(k), '.SAPFeats.mat'];
                if (exist(SAPFeatureFile, 'file'))
                    Temp = load(SAPFeatureFile);
                    Feats = Temp.Feats;
                    FeatureNames = Temp.Feats;
                    FeatureLabels = Temp.FeatureLabels;
                else
                    [Feats, RawFeats] = ASSLCalculateSAPFeatsWithOnsets(SongBout, (1:1:length(SongBout))/Fs, Fs, Onsets/1000, Offsets/1000);
                    [Feats, FeatureNames, FeatureLabels] = MA_ReAssignSAPFeats(Feats, SAPFeatureFile);
                end
                UnDirSyllFeats = [UnDirSyllFeats; Feats];

                BoutIndex = BoutIndex + 1;
            end
        end

        SyllGapStats(ParameterNo).DirSyllFeats{i} = DirSyllFeats;
        SyllGapStats(ParameterNo).UnDirSyllFeats{i} = UnDirSyllFeats;
        
    end


    for i = 1:Parameters(ParameterNo).NoPostDays,
        fprintf(' Post Day %i >>', i);
        fprintf(' Dir >>');
        
        if (exist('PlotNum', 'var'))
            BoutsToPlot = randperm(length(cell2mat(Parameters(ParameterNo).PostDirBoutLens{i})));
            BoutsToPlot = BoutsToPlot(1:min([length(BoutsToPlot) PlotNum]));
        end
        
        DirSyllFeats = [];
        BoutIndex = 1;
        for j = 1:length(Parameters(ParameterNo).PostDirBoutLens{i}),
            [RawData, Fs] = ASSLGetRawData(Parameters(ParameterNo).PostDataDir{i}, Parameters(ParameterNo).PostDirSongFileNames{i}{j}, Parameters(ParameterNo).FileType, 0);
            for k = 1:length(Parameters(ParameterNo).PostDirBoutLens{i}{j}),
                SongBout = RawData(ceil(Parameters(ParameterNo).PostDirBoutOnsets{i}{j}(k)*Fs/1000):floor(Parameters(ParameterNo).PostDirBoutOffsets{i}{j}(k)*Fs/1000));
                
                NoteFile = [NoteFileDir, Parameters(ParameterNo).PostDirSongFileNames{i}{j}, '.Bout', num2str(k), '.not.mat'];
                if (exist(NoteFile, 'file'))
                    Temp = load(NoteFile);
                    Onsets = Temp.onsets;
                    Offsets = Temp.offsets;
                else
                    BoutOnset = Parameters(ParameterNo).PostDirBoutOnsets{i}{j}(k);
                    BoutOffset = Parameters(ParameterNo).PostDirBoutOffsets{i}{j}(k);
                    [Onsets, Offsets] = MA_AnalyseSavedData_SegmentFilesAronovFee(SongBout, Fs, min_int, min_dur, NoteFile, BoutOnset, BoutOffset);
                end

                if (exist('PlotNum', 'var'))
                    if (~isempty(find(BoutsToPlot == BoutIndex)))
                        PlotSpectrogram_SongVar(SongBout, Fs);
                        for OnNo = 1:length(Onsets),
                            plot([Onsets(OnNo) Onsets(OnNo) Offsets(OnNo) Offsets(OnNo)]/1000, [300 8000 8000 300], 'b', 'LineWidth', 2);
                        end
                    end
                end
                
                SAPFeatureFile = [SAPFeatFileDir, Parameters(ParameterNo).PostDirSongFileNames{i}{j}, '.Bout', num2str(k), '.SAPFeats.mat'];
                if (exist(SAPFeatureFile, 'file'))
                    Temp = load(SAPFeatureFile);
                    Feats = Temp.Feats;
                    FeatureNames = Temp.Feats;
                    FeatureLabels = Temp.FeatureLabels;
                else
                    [Feats, RawFeats] = ASSLCalculateSAPFeatsWithOnsets(SongBout, (1:1:length(SongBout))/Fs, Fs, Onsets/1000, Offsets/1000);
                    [Feats, FeatureNames, FeatureLabels] = MA_ReAssignSAPFeats(Feats, SAPFeatureFile);
                end
                DirSyllFeats = [DirSyllFeats; Feats];
                
                BoutIndex = BoutIndex + 1;
            end
        end

        fprintf(' Undir >>');
        
        if (exist('PlotNum', 'var'))
            BoutsToPlot = randperm(length(cell2mat(Parameters(ParameterNo).PostUnDirBoutLens{i})));
            BoutsToPlot = BoutsToPlot(1:min([length(BoutsToPlot) PlotNum]));
        end
        
        UnDirSyllFeats = [];
        BoutIndex = 1;
        for j = 1:length(Parameters(ParameterNo).PostUnDirBoutLens{i}),
            [RawData, Fs] = ASSLGetRawData(Parameters(ParameterNo).PostDataDir{i}, Parameters(ParameterNo).PostUnDirSongFileNames{i}{j}, Parameters(ParameterNo).FileType, 0);
            for k = 1:length(Parameters(ParameterNo).PostUnDirBoutLens{i}{j}),
                SongBout = RawData(ceil(Parameters(ParameterNo).PostUnDirBoutOnsets{i}{j}(k)*Fs/1000):floor(Parameters(ParameterNo).PostUnDirBoutOffsets{i}{j}(k)*Fs/1000));
                
                NoteFile = [NoteFileDir, Parameters(ParameterNo).PostUnDirSongFileNames{i}{j}, '.Bout', num2str(k), '.not.mat'];
                if (exist(NoteFile, 'file'))
                    Temp = load(NoteFile);
                    Onsets = Temp.onsets;
                    Offsets = Temp.offsets;
                else
                    BoutOnset = Parameters(ParameterNo).PostUnDirBoutOnsets{i}{j}(k);
                    BoutOffset = Parameters(ParameterNo).PostUnDirBoutOffsets{i}{j}(k);
                    [Onsets, Offsets] = MA_AnalyseSavedData_SegmentFilesAronovFee(SongBout, Fs, min_int, min_dur, NoteFile, BoutOnset, BoutOffset);
                end

                if (exist('PlotNum', 'var'))
                    if (~isempty(find(BoutsToPlot == BoutIndex)))
                        PlotSpectrogram_SongVar(SongBout, Fs);
                        for OnNo = 1:length(Onsets),
                            plot([Onsets(OnNo) Onsets(OnNo) Offsets(OnNo) Offsets(OnNo)]/1000, [300 8000 8000 300], 'b', 'LineWidth', 2);
                        end
                    end
                end
                
                SAPFeatureFile = [SAPFeatFileDir, Parameters(ParameterNo).PostUnDirSongFileNames{i}{j}, '.Bout', num2str(k), '.SAPFeats.mat'];
                if (exist(SAPFeatureFile, 'file'))
                    Temp = load(SAPFeatureFile);
                    Feats = Temp.Feats;
                    FeatureNames = Temp.FeatureNames;
                    FeatureLabels = Temp.FeatureLabels;
                else
                    [Feats, RawFeats] = ASSLCalculateSAPFeatsWithOnsets(SongBout, (1:1:length(SongBout))/Fs, Fs, Onsets/1000, Offsets/1000);
                    [Feats, FeatureNames, FeatureLabels] = MA_ReAssignSAPFeats(Feats, SAPFeatureFile);
                end
                UnDirSyllFeats = [UnDirSyllFeats; Feats];
                
                BoutIndex = BoutIndex + 1;
            end
        end

        SyllGapStats(ParameterNo).DirSyllFeats{i + Parameters(ParameterNo).NoPreDays} = DirSyllFeats;
        SyllGapStats(ParameterNo).UnDirSyllFeats{i + Parameters(ParameterNo).NoPreDays} = UnDirSyllFeats;
    end
    fprintf('\n');
end

%==========================================================================
% Plot the mean of each feature value

clear DirMedians UnDirMedians;
for FeatNo = 1:length(FeatureNames),
    if (strfind(FeatureNames{FeatNo}, 'FundamentalFrequency'))
        continue;
    end
    
    for i = 1:length(SyllGapStats),
        DirMedians(i,1) = mean(SyllGapStats(i).DirSyllFeats{PrePostDays(i,1)}(:,FeatNo));
        DirMedians(i,2) = mean(SyllGapStats(i).DirSyllFeats{PrePostDays(i,2)}(:,FeatNo));

        UnDirMedians(i,1) = mean(SyllGapStats(i).UnDirSyllFeats{PrePostDays(i,1)}(:,FeatNo));
        UnDirMedians(i,2) = mean(SyllGapStats(i).UnDirSyllFeats{PrePostDays(i,2)}(:,FeatNo));
    end

    MA_PlotVsLesionSize([Parameters.PercentTotalHVCremaining], DirMedians, UnDirMedians, [FeatureLabels{FeatNo}, '(Post/Pre)'], OutputDir, 'NorthWest', ['SyllFeats', FeatureNames{FeatNo}, '.PrevsPost'], TitleString);

    MA_PlotPreVsPost(DirMedians, UnDirMedians, [FeatureLabels{FeatNo}], OutputDir, ['SyllFeats', FeatureNames{FeatNo}], TitleString);

    MA_PlotDirVsUnDir([DirMedians(:,1) UnDirMedians(:,1)], [DirMedians(:,2) UnDirMedians(:,2)], [FeatureLabels{FeatNo}], OutputDir, ['SyllFeats', FeatureNames{FeatNo}], TitleString);
end

disp('Finished analysing syllable gap statistics');