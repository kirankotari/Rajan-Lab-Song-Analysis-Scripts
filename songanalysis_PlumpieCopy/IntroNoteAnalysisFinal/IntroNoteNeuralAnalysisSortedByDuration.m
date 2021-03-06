function [INNeuralAnalysisResults] = IntroNoteNeuralAnalysisSortedByDuration(Neural_INR, BinSize)

% Using a system for AllINPosition that keeps track of whether the intro
% note was the first, last or a middle intro note. The way I do this is by
% having 3 boolean flags for first, middle and last intro note. For
% instance if there was only one intro note, it would have the flags 1 0 1
% to indicate that is the first, it is also the last. 

% It also has 3 more flags - one for the total number of INs in that
% sequence, the second one gives the trial # for the particular sequence of
% INs and the third gives the position of the IN within that sequence. With
% all of this it should be easy to reconstruct the position and trial no of
% each IN.

Width = 0.01;
GaussianLen = 4;
IFRFs = 2000;
XGauss = 1:1:(1 + round(2 * GaussianLen * Width * (IFRFs)));
XGauss = XGauss - (length(XGauss) + 1)/2;
GaussWin = (1/((Width * IFRFs) * sqrt(2 * pi))) * exp(-(XGauss.*XGauss)/(2 * (Width * IFRFs) * (Width * IFRFs)));


Edges = -1.5:BinSize:0.2;
INEdges = -0.1:BinSize:0.1;

IFREdges = INEdges(1):1/IFRFs:INEdges(end);

PST = [];
Index = 0;

INIndex = 0;
AllINPST = [];
AllINPosition = [];

for i = 1:length(Neural_INR.NoofINs),
    if (Neural_INR.NoofINs(i) < 1)
        continue;
    end
    
    Index = Index + 1;
    MotifStartTime = Neural_INR.BoutDetails(i).onsets(Neural_INR.INs{i}(end) + 1);
    SpikeIndices = find((Neural_INR.BoutDetails(i).SpikeTimes >  (MotifStartTime + Edges(1))) & (Neural_INR.BoutDetails(i).SpikeTimes <=  (MotifStartTime + Edges(end))));
    SpikeTimes = Neural_INR.BoutDetails(i).SpikeTimes(SpikeIndices) - MotifStartTime;
    PST(Index,:) = histc(SpikeTimes, Edges);

    for j = 1:Neural_INR.NoofINs(i),
        INIndex = INIndex + 1;
        INStartTime = Neural_INR.BoutDetails(i).onsets(Neural_INR.INs{i}(j));
        SpikeIndices = find((Neural_INR.BoutDetails(i).SpikeTimes >  (INStartTime + INEdges(1))) & (Neural_INR.BoutDetails(i).SpikeTimes <=  (INStartTime + INEdges(end))));
        SpikeTimes = Neural_INR.BoutDetails(i).SpikeTimes(SpikeIndices) - INStartTime;
        AllINPST(INIndex,:) = histc(SpikeTimes, INEdges);
        AllINPosition(INIndex) = j - Neural_INR.NoofINs(i) - 1;
        AllINDur(INIndex) = Neural_INR.BoutDetails(i).offsets(Neural_INR.INs{i}(j)) - Neural_INR.BoutDetails(i).onsets(Neural_INR.INs{i}(j));
        AllINNextSyllStartTime(INIndex) = Neural_INR.BoutDetails(i).onsets(Neural_INR.INs{i}(j)+1) - INStartTime;

        IFRStartIndex = find(Neural_INR.BoutDetails(i).IFR(1,:) <= (INStartTime + Edges(1)), 1, 'last');
        IFREndIndex = find(Neural_INR.BoutDetails(i).IFR(1,:) <= (INStartTime + Edges(end)), 1, 'last');
        AllINIFR(INIndex,:) = interp1(Neural_INR.BoutDetails(i).IFR(1, IFRStartIndex:IFREndIndex), Neural_INR.BoutDetails(i).IFR(2, IFRStartIndex:IFREndIndex), INStartTime + IFREdges);
    end
    INIndex = INIndex + 1;
    INStartTime = Neural_INR.BoutDetails(i).onsets(Neural_INR.INs{i}(end) + 1);
    SpikeIndices = find((Neural_INR.BoutDetails(i).SpikeTimes >  (INStartTime + INEdges(1))) & (Neural_INR.BoutDetails(i).SpikeTimes <=  (INStartTime + INEdges(end))));
    SpikeTimes = Neural_INR.BoutDetails(i).SpikeTimes(SpikeIndices) - INStartTime;
    AllINPST(INIndex,:) = histc(SpikeTimes, INEdges);
    AllINPosition(INIndex) = 0;
    AllINDur(INIndex) = Neural_INR.BoutDetails(i).offsets(Neural_INR.INs{i}(end) + 1) - Neural_INR.BoutDetails(i).onsets(Neural_INR.INs{i}(end) + 1);
    if ((Neural_INR.INs{i}(end) + 2) <= length(Neural_INR.BoutDetails(i).onsets))
        AllINNextSyllStartTime(INIndex) = Neural_INR.BoutDetails(i).onsets(Neural_INR.INs{i}(end) + 2) - INStartTime;
    else
        AllINNextSyllStartTime(INIndex) = 5;
    end
    
    IFRStartIndex = find(Neural_INR.BoutDetails(i).IFR(1,:) <= (INStartTime + Edges(1)), 1, 'last');
    IFREndIndex = find(Neural_INR.BoutDetails(i).IFR(1,:) <= (INStartTime + Edges(end)), 1, 'last');
    AllINIFR(INIndex,:) = interp1(Neural_INR.BoutDetails(i).IFR(1, IFRStartIndex:IFREndIndex), Neural_INR.BoutDetails(i).IFR(2, IFRStartIndex:IFREndIndex), INStartTime + IFREdges);
end

for i = 1:size(Neural_INR.WithinBoutNoofINs,1),
    if (Neural_INR.WithinBoutNoofINs(i,1) < 1)
        continue;
    end
    
    Index = Index + 1;
    MotifStartTime = Neural_INR.BoutDetails(Neural_INR.WithinBoutINBoutIndices(i)).onsets(Neural_INR.WithinBoutINs{i}(end) + 1);
    SpikeIndices = find((Neural_INR.BoutDetails(Neural_INR.WithinBoutINBoutIndices(i)).SpikeTimes >  (MotifStartTime + Edges(1))) & (Neural_INR.BoutDetails(Neural_INR.WithinBoutINBoutIndices(i)).SpikeTimes <=  (MotifStartTime + Edges(end))));
    SpikeTimes = Neural_INR.BoutDetails(Neural_INR.WithinBoutINBoutIndices(i)).SpikeTimes(SpikeIndices) - MotifStartTime;
    PST(Index,:) = histc(SpikeTimes, Edges);
    for j = 1:Neural_INR.WithinBoutNoofINs(i,1),
        INIndex = INIndex + 1;
        INStartTime = Neural_INR.BoutDetails(Neural_INR.WithinBoutINBoutIndices(i)).onsets(Neural_INR.WithinBoutINs{i}(j));
        SpikeIndices = find((Neural_INR.BoutDetails(Neural_INR.WithinBoutINBoutIndices(i)).SpikeTimes >  (INStartTime + INEdges(1))) & (Neural_INR.BoutDetails(Neural_INR.WithinBoutINBoutIndices(i)).SpikeTimes <=  (INStartTime + INEdges(end))));
        SpikeTimes = Neural_INR.BoutDetails(Neural_INR.WithinBoutINBoutIndices(i)).SpikeTimes(SpikeIndices) - INStartTime;
        AllINPST(INIndex,:) = histc(SpikeTimes, INEdges);
        AllINPosition(INIndex) = j - Neural_INR.WithinBoutNoofINs(i,1) - 1;
        AllINDur(INIndex) = Neural_INR.BoutDetails(Neural_INR.WithinBoutINBoutIndices(i)).offsets(Neural_INR.WithinBoutINs{i}(j)) - Neural_INR.BoutDetails(Neural_INR.WithinBoutINBoutIndices(i)).onsets(Neural_INR.WithinBoutINs{i}(j));
        AllINNextSyllStartTime(INIndex) = Neural_INR.BoutDetails(Neural_INR.WithinBoutINBoutIndices(i)).onsets(Neural_INR.WithinBoutINs{i}(j)+1) - INStartTime;
        
        IFRStartIndex = find(Neural_INR.BoutDetails(Neural_INR.WithinBoutINBoutIndices(i)).IFR(1,:) <= (INStartTime + Edges(1)), 1, 'last');
        IFREndIndex = find(Neural_INR.BoutDetails(Neural_INR.WithinBoutINBoutIndices(i)).IFR(1,:) <= (INStartTime + Edges(end)), 1, 'last');
        AllINIFR(INIndex,:) = interp1(Neural_INR.BoutDetails(Neural_INR.WithinBoutINBoutIndices(i)).IFR(1, IFRStartIndex:IFREndIndex), Neural_INR.BoutDetails(Neural_INR.WithinBoutINBoutIndices(i)).IFR(2, IFRStartIndex:IFREndIndex), INStartTime + IFREdges);
    end
    INIndex = INIndex + 1;
    INStartTime = Neural_INR.BoutDetails(Neural_INR.WithinBoutINBoutIndices(i)).onsets(Neural_INR.WithinBoutINs{i}(end) + 1);
    SpikeIndices = find((Neural_INR.BoutDetails(Neural_INR.WithinBoutINBoutIndices(i)).SpikeTimes >  (INStartTime + INEdges(1))) & (Neural_INR.BoutDetails(Neural_INR.WithinBoutINBoutIndices(i)).SpikeTimes <=  (INStartTime + INEdges(end))));
    SpikeTimes = Neural_INR.BoutDetails(Neural_INR.WithinBoutINBoutIndices(i)).SpikeTimes(SpikeIndices) - INStartTime;
    AllINPST(INIndex,:) = histc(SpikeTimes, INEdges);
    AllINPosition(INIndex) = 0;
    AllINDur(INIndex) = Neural_INR.BoutDetails(Neural_INR.WithinBoutINBoutIndices(i)).offsets(Neural_INR.WithinBoutINs{i}(end) + 1) - Neural_INR.BoutDetails(Neural_INR.WithinBoutINBoutIndices(i)).onsets(Neural_INR.WithinBoutINs{i}(end) + 1);
    AllINNextSyllStartTime(INIndex) = Neural_INR.BoutDetails(Neural_INR.WithinBoutINBoutIndices(i)).onsets(Neural_INR.WithinBoutINs{i}(end) + 2) - INStartTime;
    IFRStartIndex = find(Neural_INR.BoutDetails(Neural_INR.WithinBoutINBoutIndices(i)).IFR(1,:) <= (INStartTime + Edges(1)), 1, 'last');
    IFREndIndex = find(Neural_INR.BoutDetails(Neural_INR.WithinBoutINBoutIndices(i)).IFR(1,:) <= (INStartTime + Edges(end)), 1, 'last');
    AllINIFR(INIndex,:) = interp1(Neural_INR.BoutDetails(Neural_INR.WithinBoutINBoutIndices(i)).IFR(1, IFRStartIndex:IFREndIndex), Neural_INR.BoutDetails(Neural_INR.WithinBoutINBoutIndices(i)).IFR(2, IFRStartIndex:IFREndIndex), INStartTime + IFREdges);
end

INNeuralAnalysisResults.PST = PST;
INNeuralAnalysisResults.AllINPST = AllINPST;
INNeuralAnalysisResults.AllINPosition = AllINPosition;
INNeuralAnalysisResults.AllINDur = AllINDur;
INNeuralAnalysisResults.AllINIFR = AllINIFR;
INNeuralAnalysisResults.AllINNextSyllStartTime = AllINNextSyllStartTime;

disp('Finished Analysis');