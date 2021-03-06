function [] = PlotSyllableGapStatistics(DirFileInfo, UnDirFileInfo, Motif, MedianMotif, MainFigure)

figure(MainFigure);

axes('Position',[0.45 0.15 0.5 0.2]);
set(gca,'Box','off');
hold on;

MaxLength = 0;
MinLength = 1;

SyllCounter = 1;
GapCounter = 1;

if (isfield(DirFileInfo,'SongLengths'))
    DirNoofSongs = length(DirFileInfo.SongLengths);
    for i = 1:((size(DirFileInfo.Syllables.Length,2)) + (size(DirFileInfo.Gaps.Length,2))),
        if (mod(i,2) == 1)
            plot((ones(DirNoofSongs,1)*(2*i)),DirFileInfo.Syllables.Length(:,SyllCounter),'k+','MarkerSize',2);
            MaxLength = max(max(DirFileInfo.Syllables.Length(:,SyllCounter)),MaxLength);
            MinLength = min(min(DirFileInfo.Syllables.Length(:,SyllCounter)),MinLength);                
            SyllCounter = SyllCounter + 1;
        else
            plot((ones(DirNoofSongs,1)*(2*i)),DirFileInfo.Gaps.Length(:,GapCounter),'k+','MarkerSize',2);
            MaxLength = max(max(DirFileInfo.Gaps.Length(:,GapCounter)),MaxLength);
            MinLength = min(min(DirFileInfo.Gaps.Length(:,GapCounter)),MinLength);                            
            GapCounter = GapCounter + 1;            
        end
    end
end

SyllCounter = 1;
GapCounter = 1;

if (isfield(UnDirFileInfo,'SongLengths'))
    UnDirNoofSongs = length(UnDirFileInfo.SongLengths);
    for i = 1:((size(UnDirFileInfo.Syllables.Length,2)) + (size(UnDirFileInfo.Gaps.Length,2))),
        if (mod(i,2) == 1)
            plot((ones(UnDirNoofSongs,1)*(2*i) + 1),UnDirFileInfo.Syllables.Length(:,SyllCounter),'Marker','+','LineStyle','none','MarkerEdgeColor',[0.6 0.6 0.6],'MarkerSize',2);
            MaxLength = max(max(UnDirFileInfo.Syllables.Length(:,SyllCounter)),MaxLength);
            MinLength = min(min(UnDirFileInfo.Syllables.Length(:,SyllCounter)),MinLength);                
            SyllCounter = SyllCounter + 1;
        else
            plot((ones(UnDirNoofSongs,1)*(2*i) + 1),UnDirFileInfo.Gaps.Length(:,GapCounter),'Marker','+','LineStyle','none','MarkerEdgeColor',[0.6 0.6 0.6],'MarkerSize',2);
            MaxLength = max(max(UnDirFileInfo.Gaps.Length(:,GapCounter)),MaxLength);
            MinLength = min(min(UnDirFileInfo.Gaps.Length(:,GapCounter)),MinLength);
            GapCounter = GapCounter + 1;            
        end
    end
end

for MotifIndex = 1:length(Motif),
    XTICKS(MotifIndex) = (MotifIndex-1)*4 + 2;
    XTICKLABELS{MotifIndex} = Motif(MotifIndex);
end


axis([0.5 (2*i + 1.5) (MinLength*0.95) (MaxLength*1.05)]);
set(gca,'FontSize',10,'FontWeight','bold');
set(gca,'Xtick',([XTICKS] + 0.5),'XTickLabel',XTICKLABELS);
ylabel('Time (sec)','FontSize',10,'FontWeight','bold');    
title('Gap and Syllable Lengths','FontSize',12,'FontWeight','bold');    