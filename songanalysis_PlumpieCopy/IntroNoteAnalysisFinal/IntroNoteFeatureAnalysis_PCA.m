function [INFAnalysisResults] = IntroNoteFeatureAnalysis_PCA(IntroNoteResults, BoutType, varargin)

% Using a system for AllINFeatLabels that keeps track of whether the intro
% note was the first, last or a middle intro note. The way I do this is by
% having 3 boolean flags for first, middle and last intro note. For
% instance if there was only one intro note, it would have the flags 1 0 1
% to indicate that is the first, it is also the last.

if (nargin > 2)
    PCA_Coeff = varargin{1};
    PCA_Var = varargin{2};
end
MinNumber = 2;

AllINFeats = [];
AllINFeatLabels = [];
AllINFeatNoofINs = [];
for i = 1:length(IntroNoteResults.NoofINs),
    TempFeats = IntroNoteResults.BoutDetails(i).Feats(IntroNoteResults.INs{i},:);
    AllINFeats = [AllINFeats; TempFeats];
    AllINFeatNoofINs = [AllINFeatNoofINs; ones(size(TempFeats,1),1)*size(TempFeats,1)];
    if (~isempty(TempFeats))
        if (size(TempFeats,1) == 1)
            AllINFeatLabels = [AllINFeatLabels; [[1 0 1] [-size(TempFeats,1):1:-1]'] [1:1:size(TempFeats,1)]' ones(size(TempFeats,1),1)]; 
        else
            if (size(TempFeats,1) == 2)
                AllINFeatLabels = [AllINFeatLabels; [[1 0 0; 0 0 1] [-size(TempFeats,1):1:-1]'] [1:1:size(TempFeats,1)]' ones(size(TempFeats,1),1)];
            else
                AllINFeatLabels = [AllINFeatLabels; [[1 0 0; repmat([0 1 0], (size(TempFeats,1)-2), 1); [0 0 1]] [-size(TempFeats,1):1:-1]'] [1:1:size(TempFeats,1)]' ones(size(TempFeats,1),1)];
            end
        end
    end
end

BoutIndices = find(IntroNoteResults.WithinBoutNoofINs(:,1) > 0);
for i = 1:length(BoutIndices),
    TempFeats = IntroNoteResults.BoutDetails(IntroNoteResults.WithinBoutINBoutIndices(BoutIndices(i))).Feats(IntroNoteResults.WithinBoutINs{BoutIndices(i)},:);
    AllINFeats = [AllINFeats; TempFeats];
    AllINFeatNoofINs = [AllINFeatNoofINs; ones(size(TempFeats,1),1)*size(TempFeats,1)];
    if (~isempty(TempFeats))
        if (size(TempFeats,1) == 1)
            AllINFeatLabels = [AllINFeatLabels; [[1 0 1] [-size(TempFeats,1):1:-1]'] [1:1:size(TempFeats,1)]' ones(size(TempFeats,1),1)*2]; 
        else
            if (size(TempFeats,1) == 2)
                AllINFeatLabels = [AllINFeatLabels; [[1 0 0; 0 0 1] [-size(TempFeats,1):1:-1]'] [1:1:size(TempFeats,1)]' ones(size(TempFeats,1),1)*2];
            else
                AllINFeatLabels = [AllINFeatLabels; [[1 0 0; repmat([0 1 0], (size(TempFeats,1)-2), 1); [0 0 1]] [-size(TempFeats,1):1:-1]'] [1:1:size(TempFeats,1)]' ones(size(TempFeats,1),1)*2];
            end
        end
    end
end

MeanAllINFeats = mean(AllINFeats);
STDAllINFeats = std(AllINFeats,1);

NormAllINFeats = (AllINFeats - repmat(MeanAllINFeats, size(AllINFeats, 1), 1))./repmat(STDAllINFeats, size(AllINFeats, 1), 1);
% NormAllINFeats = (AllINFeats)./repmat(STDAllINFeats, size(AllINFeats, 1), 1);
if (~exist('PCA_Coeff', 'var'))
    [Rows, Cols] = find(abs(NormAllINFeats) > 3);
    NonOutlierRows = setdiff((1:1:size(NormAllINFeats,1)), unique(Rows));
    disp(['Removed ', num2str(length(unique(Rows))), ' rows from the data as they were outliers']);
    [PCA_Coeff, PCA_ScoreAllINFeats, PCA_Var] = princomp(NormAllINFeats(NonOutlierRows,1:end));
else
    PCA_ScoreAllINFeats = NormAllINFeats(:,1:end)*PCA_Coeff;
end
%[PCA_Coeff, PCA_ScoreAllINFeats, PCA_Var] = princomp(NormAllINFeats);
MaxINs = max([max(IntroNoteResults.NoofINs) max(IntroNoteResults.WithinBoutNoofINs(:,1))]);

for i = 1:MaxINs,
    INFeats{i} = [];
end

switch BoutType
    case 'Beginning'
        for i = 1:MaxINs,
            INFeats{i} = [];
            for j = 1:length(IntroNoteResults.NoofINs),
                if (IntroNoteResults.NoofINs(j) == i)
                    INFeats{i} = [INFeats{i}; [IntroNoteResults.BoutDetails(j).Feats([IntroNoteResults.INs{j}],:) (i:-1:1)']];
                end
            end
        end
        
    case 'Within'
        BoutIndices = find(IntroNoteResults.WithinBoutNoofINs(:,1) > 0);
        for i = 1:MaxINs,
            if (i > length(INFeats))
                INFeats{i} = [];
            end
            for j = 1:length(BoutIndices),
                if (IntroNoteResults.WithinBoutNoofINs(BoutIndices(j),1) == i)
                    INFeats{i} = [INFeats{i}; [IntroNoteResults.BoutDetails(IntroNoteResults.WithinBoutINBoutIndices(BoutIndices(j))).Feats(IntroNoteResults.WithinBoutINs{BoutIndices(j)},:) (i:-1:1)']];
                end
            end
        end
        
    case 'All'
        for i = 1:MaxINs,
            INFeats{i} = [];
            for j = 1:length(IntroNoteResults.NoofINs),
                if (IntroNoteResults.NoofINs(j) == i)
                    INFeats{i} = [INFeats{i}; [IntroNoteResults.BoutDetails(j).Feats([IntroNoteResults.INs{j}],:) (i:-1:1)']];
                end
            end
        end
        
        BoutIndices = find(IntroNoteResults.WithinBoutNoofINs(:,1) > 0);
        for i = 1:MaxINs,
            if (i > length(INFeats))
                INFeats{i} = [];
            end
            for j = 1:length(BoutIndices),
                if (IntroNoteResults.WithinBoutNoofINs(BoutIndices(j),1) == i)
                    INFeats{i} = [INFeats{i}; [IntroNoteResults.BoutDetails(IntroNoteResults.WithinBoutINBoutIndices(BoutIndices(j))).Feats(IntroNoteResults.WithinBoutINs{BoutIndices(j)},:) (i:-1:1)']];
                end
            end
        end
end

for i = 1:MaxINs,
    if (~isempty(INFeats{i}))
        NormINFeats{i} = (INFeats{i}(:,1:end-1) - repmat(MeanAllINFeats, size(INFeats{i},1), 1))./repmat(STDAllINFeats, size(INFeats{i},1),1);
        % NormINFeats{i} = (INFeats{i}(:,1:end-1))./repmat(STDAllINFeats, size(INFeats{i},1),1);
        PCA_ScoreINFeats{i} = NormINFeats{i}(:,1:end)*PCA_Coeff;
    end
end

% figure;
% hold on;
% Colours = ['rcygk'];
% Symbols = ['sdvp'];

% for i = 1:length(PCA_ScoreINFeats),
%     if (~isempty(PCA_ScoreINFeats{i}))
%         if (size(PCA_ScoreINFeats{i},1) < 2*i)
%             continue;
%         end
%         for j = 1:i:min([size(PCA_ScoreINFeats{i}, 1) 25*i]),
%             % plot3(-INFeats{i}(j:j+i-1,end), PCA_ScoreINFeats{i}(j:j+i-1,1), PCA_ScoreINFeats{i}(j:j+i-1,2), 'Color', [0.7 0.7 0.7], 'LineWidth', 1.25);
%             % plot3(PCA_ScoreINFeats{i}(j:j+i-1,1), PCA_ScoreINFeats{i}(j:j+i-1,2), PCA_ScoreINFeats{i}(j:j+i-1,3), Colours(mod(abs(i),length(Colours))+1), 'LineWidth', 0.25);
%             plot(-INFeats{i}(j:j+i-1,end), mean(PCA_ScoreINFeats{i}(j:j+i-1,1), PCA_ScoreINFeats{i}(j:j+i-1,2), 'Color', [0.7 0.7 0.7], 'LineWidth', 1.25);
%             if (i > 1)
%                 %for k = 0:i-2,
%                 for k = 0,
%                     %plot3(-INFeats{i}(j+k,end), PCA_ScoreINFeats{i}(j+k,1), PCA_ScoreINFeats{i}(j+k,2), [Colours(mod(abs(k-i),length(Colours))+1), Symbols(mod(floor(i/length(Colours)), length(Symbols)) + 1)], 'MarkerSize', 3.5, 'MarkerFaceColor', Colours(mod(abs(k-i),length(Colours)) + 1));
%                     plot3(PCA_ScoreINFeats{i}(j+k,1), PCA_ScoreINFeats{i}(j+k,2), PCA_ScoreINFeats{i}(j+k,3), [Colours(mod(abs(k),length(Colours))+1), Symbols(mod(floor(i/length(Colours)), length(Symbols)) + 1)], 'MarkerSize', 3.5, 'MarkerFaceColor', Colours(mod(abs(k),length(Colours)) + 1));
%                 end
%             end
%             %plot3(-INFeats{i}(j+i-1,end), PCA_ScoreINFeats{i}(j+i-1,1), PCA_ScoreINFeats{i}(j+i-1,2), 'bo', 'MarkerSize', 3.5, 'MarkerFaceColor', 'b');
%             plot3(PCA_ScoreINFeats{i}(j+i-1,1), PCA_ScoreINFeats{i}(j+i-1,2), PCA_ScoreINFeats{i}(j+i-1,3), 'bo', 'MarkerSize', 3.5, 'MarkerFaceColor', 'b');
%         end
%     end
% end
% axis tight;
% axis tight;
% set(gca, 'XGrid', 'on');
% set(gca, 'YGrid', 'on');
% set(gca, 'ZGrid', 'on');
% set(gca, 'FontSize', 10, 'FontName', 'Arial');
% set(gcf, 'Color', 'w');
% view(3);
% 
% figure;
% hold on;
% for i = 1:length(PCA_ScoreINFeats),
%     if (~isempty(PCA_ScoreINFeats{i}))
%         if (size(PCA_ScoreINFeats{i},1) < 2*i)
%             continue;
%         end
%         for j = 1:i:min([size(PCA_ScoreINFeats{i}, 1) 25*i]),
%             plot(PCA_ScoreINFeats{i}(j:j+i-1,1), PCA_ScoreINFeats{i}(j:j+i-1,2), Colours(mod(abs(i),length(Colours))+1), 'LineWidth', 0.25);
% %             if (i > 1)
% %                 %for k = 0:i-2,
% %                 for k = 0,
% %                     %plot3(-INFeats{i}(j+k,end), PCA_ScoreINFeats{i}(j+k,1), PCA_ScoreINFeats{i}(j+k,2), [Colours(mod(abs(k-i),length(Colours))+1), Symbols(mod(floor(i/length(Colours)), length(Symbols)) + 1)], 'MarkerSize', 3.5, 'MarkerFaceColor', Colours(mod(abs(k-i),length(Colours)) + 1));
% %                     plot3(PCA_ScoreINFeats{i}(j+k,1), PCA_ScoreINFeats{i}(j+k,2), PCA_ScoreINFeats{i}(j+k,3), [Colours(mod(abs(k),length(Colours))+1), Symbols(mod(floor(i/length(Colours)), length(Symbols)) + 1)], 'MarkerSize', 3.5, 'MarkerFaceColor', Colours(mod(abs(k),length(Colours)) + 1));
% %                 end
% %             end
%             plot(PCA_ScoreINFeats{i}(j+i-1,1), PCA_ScoreINFeats{i}(j+i-1,2), 'bo', 'MarkerSize', 3.5, 'MarkerFaceColor', 'b');
%         end
%     end
% end
% axis tight;
% axis tight;
% set(gca, 'FontSize', 10, 'FontName', 'Arial');
% set(gcf, 'Color', 'w');
% 
% figure;
% hold on;
% for i = 1:length(PCA_ScoreINFeats),
%     if (~isempty(PCA_ScoreINFeats{i}))
%         if (size(PCA_ScoreINFeats{i},1) < 2*i)
%             continue;
%         end
%         for j = 1:i,
%             MeanPCA_ScoreINFeats{i}(j,:) = mean(PCA_ScoreINFeats{i}(j:i:end,:));
%             STDPCA_ScoreINFeats{i}(j,:) = std(PCA_ScoreINFeats{i}(j:i:end,:));
%             SEMPCA_ScoreINFeats{i}(j,:) = std(PCA_ScoreINFeats{i}(j:i:end,:))/sqrt(size(PCA_ScoreINFeats{i},1)/i);
%         end
%         %errorbar(-INFeats{i}(1:i,end), MeanPCA_ScoreINFeats{i}(:,1),
%         %SEMPCA_ScoreINFeats{i}(:,1), [Colours(mod(abs(i),length(Colours))+1), Symbols(mod(floor(i/length(Colours)), length(Symbols)) + 1), '-'], 'MarkerSize', 3.5);
%         plot(MeanPCA_ScoreINFeats{i}(:,1), MeanPCA_ScoreINFeats{i}(:,2), [Colours(mod(abs(i),length(Colours))+1), Symbols(mod(floor(i/length(Colours)), length(Symbols)) + 1), '-'], 'MarkerSize', 3.5);
%     end
% end
% axis tight;
% axis tight;
% set(gca, 'FontSize', 10, 'FontName', 'Arial');
% set(gcf, 'Color', 'w');

figure;
Colours = 'rbkgymk';

for i = -1:-1:max([-7, min(AllINFeatLabels(:,4))]),
    Indices = find(AllINFeatLabels(:,4) == i);
    if (length(Indices) > 4)
        plot3(PCA_ScoreAllINFeats(Indices,1), PCA_ScoreAllINFeats(Indices,2), PCA_ScoreAllINFeats(Indices,3), [Colours(abs(i)),'o'], 'MarkerSize', 4, 'MarkerFaceColor', Colours(abs(i)));
        hold on;
        PlotEllipsoid(PCA_ScoreAllINFeats(Indices,1:3), Colours(abs(i)), 1);
    end
end
axis tight;
view(2);

figure;
Colours = 'rbkgymk';

for i = 1:1:min([7, max(AllINFeatLabels(:,5))]),
    Indices = find(AllINFeatLabels(:,5) == i);
    if (length(Indices) > 4)
        plot3(PCA_ScoreAllINFeats(Indices,1), PCA_ScoreAllINFeats(Indices,2), PCA_ScoreAllINFeats(Indices,3), [Colours(abs(i)),'o'], 'MarkerSize', 4, 'MarkerFaceColor', Colours(abs(i)));
        hold on;
        PlotEllipsoid(PCA_ScoreAllINFeats(Indices,1:3), Colours(abs(i)), 2);
    end
end
axis tight;
view(2);

figure;
Colours = 'rbkgymk';

for i = 1:max(AllINFeatNoofINs),
    Indices = find((AllINFeatNoofINs == i) & (AllINFeatLabels(:,3) == 1));
    if (length(Indices) > 4)
        plot3(PCA_ScoreAllINFeats(Indices,1), PCA_ScoreAllINFeats(Indices,2), PCA_ScoreAllINFeats(Indices,3), [Colours(abs(i)),'o'], 'MarkerSize', 4, 'MarkerFaceColor', Colours(abs(i)));
        hold on;
        PlotEllipsoid(PCA_ScoreAllINFeats(Indices,1:3), Colours(abs(i)), 2);
    end
end
axis tight;
view(2);

figure;
Colours = 'rbkgymk';

for i = 1:2,
    Indices = find((AllINFeatLabels(:,6) == i) & (AllINFeatLabels(:,3) == 1));
    if (length(Indices) > 4)
        plot3(PCA_ScoreAllINFeats(Indices,1), PCA_ScoreAllINFeats(Indices,2), PCA_ScoreAllINFeats(Indices,3), [Colours(abs(i)),'o'], 'MarkerSize', 4, 'MarkerFaceColor', Colours(abs(i)));
        hold on;
        PlotEllipsoid(PCA_ScoreAllINFeats(Indices,1:3), Colours(abs(i)), 2);
    end
end
axis tight;
view(2);

% figure;
% hold on;
% plot3(NormAllINFeats(find(AllINFeatLabels(:,1) == 1),1), NormAllINFeats(find(AllINFeatLabels(:,1) == 1),2), NormAllINFeats(find(AllINFeatLabels(:,1) == 1),3), 'ro', 'MarkerSize', 3, 'MarkerFaceColor', 'r');
% plot3(NormAllINFeats(find(AllINFeatLabels(:,3) == 1),1), NormAllINFeats(find(AllINFeatLabels(:,3) == 1),2), NormAllINFeats(find(AllINFeatLabels(:,3) == 1),3), 'bo', 'MarkerSize', 3, 'MarkerFaceColor', 'b');
% axis tight;
% set(gca, 'XGrid', 'on');
% set(gca, 'YGrid', 'on');
% set(gca, 'ZGrid', 'on');
% set(gca, 'FontSize', 10, 'FontName', 'Arial');
% set(gcf, 'Color', 'w');
% view(3);

INFAnalysisResults.AllINFeats = AllINFeats;
INFAnalysisResults.NormAllINFeats = NormAllINFeats;
INFAnalysisResults.PCA_ScoreAllINFeats = PCA_ScoreAllINFeats;
INFAnalysisResults.PCA_Coeff = PCA_Coeff;
INFAnalysisResults.PCA_Var = PCA_Var;
INFAnalysisResults.AllINFeatLabels = AllINFeatLabels;
INFAnalysisResults.AllINFeatNoofINs = AllINFeatNoofINs;

INFAnalysisResults.INFeats = INFeats;
INFAnalysisResults.NormINFeats = NormINFeats;
INFAnalysisResults.PCA_ScoreINFeats = PCA_ScoreINFeats;

INFAnalysisResults.MeanAllINFeats = MeanAllINFeats;
INFAnalysisResults.STDAllINFeats = STDAllINFeats;

INFAnalysisResults.D_LL = pdist(PCA_ScoreAllINFeats(find(AllINFeatLabels(:,3) == 1),:));
INFAnalysisResults.D_FF = pdist(PCA_ScoreAllINFeats(find(AllINFeatLabels(:,1) == 1),:));
INFAnalysisResults.D_MM = pdist(PCA_ScoreAllINFeats(find(AllINFeatLabels(:,2) == 1),:));

MeanLastIN = mean(PCA_ScoreAllINFeats(find((AllINFeatLabels(:,3) == 1) & (AllINFeatLabels(:,1) == 0)),:)); % this excludes all cases where only 1 IN is present
INFAnalysisResults.MeanLastIN = MeanLastIN;

MeanFirstIN = mean(PCA_ScoreAllINFeats(find((AllINFeatLabels(:,1) == 1) & (AllINFeatLabels(:,3) == 0)),:)); % this excludes all cases where only 1 IN is present
INFAnalysisResults.MeanFirstIN = MeanFirstIN;

FirstINIndices = find(AllINFeatLabels(:,1) == 1);
FirstINNoofINs = AllINFeatNoofINs(FirstINIndices);

D_FL = pdist2(PCA_ScoreAllINFeats(FirstINIndices,:), MeanLastIN);
INFAnalysisResults.D_FL = D_FL;
INFAnalysisResults.D_MeanLastIN = pdist2(PCA_ScoreAllINFeats, MeanLastIN);

DistanceToLast = ones(MaxINs, 3);

for i = 1:MaxINs,
    Indices = find(FirstINNoofINs == i);
    if (length(Indices) > MinNumber)
        DistanceToLast(i,:) = [mean(D_FL(Indices)) std(D_FL(Indices)) std(D_FL(Indices))/sqrt(length(Indices))];
    else
        DistanceToLast(i,:) = [NaN NaN NaN];
    end
    Indices = find((AllINFeatNoofINs == i) & (AllINFeatLabels(:,1) == 1));
    if (length(Indices) > MinNumber)
        IN_D_FF(i) = mean(pdist(PCA_ScoreAllINFeats(Indices,:)));
    end
end

INFAnalysisResults.PosBasedDistanceToLast = [];
INFAnalysisResults.PosBasedVar = [];
INFAnalysisResults.DistToLast = pdist2(PCA_ScoreAllINFeats(:,1:3), MeanLastIN(:,1:3));
for i = min(AllINFeatLabels(:,4)):1:max(AllINFeatLabels(:,4));
    if (length(find(AllINFeatLabels(:,4) == i)) > 4)
        Indices = find(AllINFeatLabels(:,4) == i);
        INFAnalysisResults.PosBasedDistanceToLast = [INFAnalysisResults.PosBasedDistanceToLast; [i median(INFAnalysisResults.DistToLast(Indices))]];
        INFAnalysisResults.PosBasedVar = [INFAnalysisResults.PosBasedVar; [i median(pdist(PCA_ScoreAllINFeats(Indices,1:3)))]];
    end
end

INFAnalysisResults.PosBasedDistanceToFirst = [];
INFAnalysisResults.PosBasedVarFirst = [];
INFAnalysisResults.DistToFirst = pdist2(PCA_ScoreAllINFeats(:,1:3), MeanFirstIN(:,1:3));
for i = min(AllINFeatLabels(:,5)):1:max(AllINFeatLabels(:,5));
    if (length(find(AllINFeatLabels(:,5) == i)) > 4)
        Indices = find(AllINFeatLabels(:,5) == i);
        INFAnalysisResults.PosBasedDistanceToFirst = [INFAnalysisResults.PosBasedDistanceToFirst; [i median(INFAnalysisResults.DistToFirst(Indices))]];
        INFAnalysisResults.PosBasedVarFirst = [INFAnalysisResults.PosBasedVarFirst; [i median(pdist(PCA_ScoreAllINFeats(Indices,1:3)))]];
    end
end
    
INFAnalysisResults.DistanceToLast = DistanceToLast;
INFAnalysisResults.IN_D_FF = IN_D_FF;
disp('Finished feature analysis');
