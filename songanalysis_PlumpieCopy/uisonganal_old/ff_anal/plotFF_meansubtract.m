function plotFF_meansubtract (birdname_date, note);

% This script calculate mean of FF values using a time window around each
% data point, and subtract the mean from the data value, then calculate
% variability

windur = 60 % window duration (min)
MinNoteNum = 5  % min number of notes in individual time windows to calculate local mean.

% load input files
FF_time_matfile = ['FF_',note,'_time.mat']
load (FF_time_matfile)

% sort the FF values for dir and undir
m =1; p =1;
for k=1:length(allFF)
    if length(strmatch('dir', allFF(k,1)))>0
        dirX(m) = [allFF{k,3}];
        dirY(m) = [allFF{k,2}];
        m=m+1;
    end
    if length(strmatch('undir', allFF(k,1)))>0
        undirX(p) = [allFF{k,3}];
        undirY(p) = [allFF{k,2}];
        p=p+1;
    end
end

% calculate local mean around each data point

windur = windur/60;
n=1;
for i = 1:length(dirX)
    localdata_dir = find(dirX >= dirX(i)-(windur/2) & dirX <= dirX(i)+(windur/2));
    if length(localdata_dir)>=MinNoteNum
        localdata_dirY = dirY(localdata_dir);
        localmean_dir(n) = mean(localdata_dirY);
        localdev_dir(n) = dirY(i)-localmean_dir(n);
        localcv_dir(n) = localdev_dir(n)/localmean_dir(n)*100;
        localdata_dirX(n) = dirX(i);
        n=n+1;
    end
end

n=1;
for i = 1:length(undirX)
    localdata_undir = find(undirX >= undirX(i)-(windur/2) & undirX <= undirX(i)+(windur/2));
    if length(localdata_undir)>=MinNoteNum
        localdata_undirY = undirY(localdata_undir);
        localmean_undir(n) = mean(localdata_undirY);
        localdev_undir(n) = undirY(i)-localmean_undir(n);
        localcv_undir(n) = localdev_undir(n)/localmean_undir(n)*100;
        localdata_undirX(n) = undirX(i);
        n=n+1;
    end
end

% Calculate P value for statistical significance of difference in
% variability between localcv_dir and localcv_undir using F-test
[p, F] = ftest(localcv_dir, localcv_undir);

% plot FF varlues and differece from mean
figure
subplot(2,1,1)
plot(dirX,dirY,'or'); hold on
plot(undirX,undirY,'ob'); hold on
title('Fundamental Frequency')
ylabel('FF (Hz)')

plot(localdata_dirX,localmean_dir,'--r'); hold on
plot(localdata_undirX,localmean_undir,'--b'); hold on

subplot(2,1,2)
plot(localdata_dirX,localcv_dir,'or'); hold on
plot(localdata_undirX,localcv_undir,'ob')
title('% difference from local mean (calculated 30 min window around each data point)')
xlabel('time'); ylabel('% difference')

zeroX = [fix(min([min(localdata_dirX), min(localdata_undirX)])) ceil(max([max(localdata_dirX), max(localdata_undirX)]))];
zeroY = [0 0];
plot(zeroX, zeroY, '--k')

suptitle([birdname_date, ',  "', note, '"  (red: dir;  blue: undir)'])

% save the figure
fig_name =  ['FF_',note,'_meansubtract1.fig']
saveas(gcf,fig_name)

%plot the normalized values
plot_notes4DS_UDS(' ', ' ', localcv_dir); hold on
plot_notes2(' ',' ', localcv_undir); axis auto;
title('difference from local mean')
ptext = ['p = ',num2str(p), ' (F-test)'];
text(1.05, max([max(localcv_dir),max(localcv_undir)]), ptext)
suptitle([birdname_date, ',  "', note, '"  (red: dir;  blue: undir)'])

% save the figure
fig_name2 =  ['FF_',note,'_meansubtract2.fig']
saveas(gcf,fig_name2)

%change the name of variables to output
dev_dir = localdev_dir;
deltaF_dir = localcv_dir;
dirX = localdata_dirX;
dev_undir = localdev_undir;
deltaF_undir = localcv_undir;
undirX = localdata_undirX;

% save the FF difference
saved_file_name = ['FF_', note, '_meansubtract']
save(saved_file_name,'dev_dir','localmean_dir','deltaF_dir','dirX','dev_undir','localmean_undir','deltaF_undir','undirX','F','p')
clear

