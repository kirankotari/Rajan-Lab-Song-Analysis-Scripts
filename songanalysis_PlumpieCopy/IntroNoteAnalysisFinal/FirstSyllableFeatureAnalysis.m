function [FSAnalysisResults] = FirstSyllableFeatureAnalysis(IntroNoteResults, BoutType, PlotFeatCols, LastINFeatures)

% Using a system for AllINFeatLabels that keeps track of whether the intro
% note was the first, last or a middle intro note. The way I do this is by
% having 3 boolean flags for first, middle and last intro note. For
% instance if there was only one intro note, it would have the flags 1 0 1
% to indicate that is the first, it is also the last.

MinNumber = 10;

FeatureCols = [1 2 3 4];

AllFSFeats = [];
AllINFeatNoofINs = [];
for i = 1:length(IntroNoteResults.NoofINs),
    AllFSFeats = [AllFSFeats; IntroNoteResults.BoutDetails(i).Feats(IntroNoteResults.MotifStartIndex(i),FeatureCols)];
    AllINFeatNoofINs = [AllINFeatNoofINs; IntroNoteResults.NoofINs(i)];
end


BoutIndices = find(IntroNoteResults.WithinBoutNoofINs(:,1) >= 0);
for i = 1:length(BoutIndices),
    AllFSFeats = [AllFSFeats; IntroNoteResults.BoutDetails(IntroNoteResults.WithinBoutINBoutIndices(BoutIndices(i))).Feats(IntroNoteResults.WithinBoutNoofINs(BoutIndices(i),4), FeatureCols)];
    AllINFeatNoofINs = [AllINFeatNoofINs; IntroNoteResults.WithinBoutNoofINs(BoutIndices(i),1)];
end

[Rows, Cols] = find(isnan(AllFSFeats));
AllFSFeats(unique(Rows),:) = [];
AllINFeatNoofINs(unique(Rows),:) = [];
disp(['Removed ', num2str(length(unique(Rows))), ' trials as they were NaNs']);

Colours = ['brkmcyb'];
FSAnalysisResults.DistanceToMean = [];
FSAnalysisResults.DistanceToMeanNonZeroINs = [];
FSAnalysisResults.DistanceToLastIN = [];
FSAnalysisResults.MeanFeatValues = [];

NonZeroINIndices = find(AllINFeatNoofINs > 0);

for i = min(AllINFeatNoofINs):1:max(AllINFeatNoofINs),
    Indices = find(AllINFeatNoofINs == i);
    if (length(Indices) >= MinNumber)
        figure;
        set(gcf, 'Color', 'w');
        hold on;
        %plot(mean(AllFSFeats(:,PlotFeatCols(1))), mean(AllFSFeats(:,PlotFeatCols(2))), 'g+', 'MarkerSize', 15, 'LineWidth', 3);
        plot(mean(LastINFeatures(:,PlotFeatCols(:,1))), mean(LastINFeatures(:,PlotFeatCols(:,2))), 'g+', 'MarkerSize', 15, 'LineWidth', 3);
        plot(AllFSFeats(Indices,PlotFeatCols(1)), AllFSFeats(Indices,PlotFeatCols(2)), [Colours(mod(i-1,length(Colours))+1), 's'], 'MarkerSize', 2, 'MarkerFaceColor', [Colours(mod(i-1,length(Colours))+1)]);
        plot(mean(AllFSFeats(Indices,PlotFeatCols(1))), mean(AllFSFeats(Indices,PlotFeatCols(2))), [Colours(mod(i-1,length(Colours))+1), '+'], 'MarkerSize', 15, 'LineWidth', 3);
        PlotConfidenceEllipse(AllFSFeats(Indices,PlotFeatCols(1):PlotFeatCols(2)), Colours(mod(i-1,length(Colours))+1), 1);
        FSAnalysisResults.DistanceToMean = [FSAnalysisResults.DistanceToMean; [i pdist2(mean(AllFSFeats(Indices,:)), mean(AllFSFeats), 'mahalanobis', cov(AllFSFeats))]];
        FSAnalysisResults.DistanceToLastIN = [FSAnalysisResults.DistanceToLastIN; [i pdist2(mean(AllFSFeats(Indices,:)), mean(LastINFeatures), 'mahalanobis', cov(LastINFeatures))]];
        FSAnalysisResults.DistanceToMeanNonZeroINs = [FSAnalysisResults.DistanceToMeanNonZeroINs; [i pdist2(mean(AllFSFeats(Indices,:)), mean(AllFSFeats(NonZeroINIndices,:)), 'mahalanobis', cov(AllFSFeats(NonZeroINIndices,:)))]];
        axis([min(AllFSFeats(:,PlotFeatCols(1))) max(AllFSFeats(:,PlotFeatCols(1))) min(AllFSFeats(:,PlotFeatCols(2))) max(AllFSFeats(:,PlotFeatCols(2)))]);
        FSAnalysisResults.MeanFeatValues = [FSAnalysisResults.MeanFeatValues; [i mean(AllFSFeats(Indices,:))]];
    end
end

FSAnalysisResults.AllFSFeats = AllFSFeats;
FSAnalysisResults.AllINFeatNoofINs = AllINFeatNoofINs;
