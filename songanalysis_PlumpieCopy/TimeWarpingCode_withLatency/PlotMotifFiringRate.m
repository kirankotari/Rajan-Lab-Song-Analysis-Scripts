function [DirMotifFiringRate, UnDirMotifFiringRate] = PlotMotifFiringRate(DirFileInfo, UnDirFileInfo, MainFigure)

figure(MainFigure);

axes('Position',[0.15 0.82 0.15 0.1]);
set(gca,'Box','off');
hold on;

MaxNoofSpikes = 0;

DirMotifFiringRate = [];
UnDirMotifFiringRate = [];

if (isfield(DirFileInfo,'UWSpikeTrain'))
    if (length(DirFileInfo.UWSpikeTrain) > 0)
        for i = 1:length(DirFileInfo.UWSpikeTrain),
            DirMotifNoofSpikes(i) = length([DirFileInfo.UWSpikeTrain{i}])/(DirFileInfo.SongLengths(i));
        end
        DirNoofSpikes = bar(1,mean(DirMotifNoofSpikes));
        set(DirNoofSpikes, 'EdgeColor', ' k', 'FaceColor', 'k');
        errorbar(1,mean(DirMotifNoofSpikes),std(DirMotifNoofSpikes),'k.');
        MaxNoofSpikes = max(MaxNoofSpikes,(mean(DirMotifNoofSpikes) + std(DirMotifNoofSpikes)));
        DirMotifFiringRate(1) = mean(DirMotifNoofSpikes);
        DirMotifFiringRate(2) = std(DirMotifNoofSpikes);
    end
end

if (isfield(UnDirFileInfo,'UWSpikeTrain'))
    if (length(UnDirFileInfo.UWSpikeTrain) > 0)
        for i = 1:length(UnDirFileInfo.UWSpikeTrain),
            UnDirMotifNoofSpikes(i) = length([UnDirFileInfo.UWSpikeTrain{i}])/(UnDirFileInfo.SongLengths(i));
        end
        UnDirNoofSpikes = bar(2,mean(UnDirMotifNoofSpikes));
        set(UnDirNoofSpikes, 'EdgeColor', [0.6 0.6 0.6], 'FaceColor', [0.6 0.6 0.6]);
        errorbar(2,mean(UnDirMotifNoofSpikes),std(UnDirMotifNoofSpikes),'Color',[0.6 0.6 0.6],'Marker','.');        
        MaxNoofSpikes = max(MaxNoofSpikes,(mean(UnDirMotifNoofSpikes) + std(UnDirMotifNoofSpikes)));        
        UnDirMotifFiringRate(1) = mean(UnDirMotifNoofSpikes);
        UnDirMotifFiringRate(2) = std(UnDirMotifNoofSpikes);
    end
end

axis([0 3 0 MaxNoofSpikes]);
set(gca,'FontSize',8,'FontWeight','bold');
set(gca,'Xtick',[1 2],'XTickLabel',[{'Directed'} {'Undirected'}]);
ylabel('Mean no of spikes','FontSize',8,'FontWeight','bold');    
title('No of spikes in motif','FontSize',8,'FontWeight','bold');    