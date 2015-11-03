function idx_spect=scale_spect(spect)

%this function maps the spectrogram data in spect into an index array (idx_spect) for display
%the rationale for doing this is so that after calculation of batch files, display speed will be maximized
% (i.e. no additional manipulations of data are needed, only of colormap)
% spect is assumed to be in db re maximum value of spect 
% idx_spect is an index array for display of spectrogram such that 
% the maximum value of idx_spect


%make sure no zero values in spect:
max_val=max(max(spect));
%spect=max(.000000001*max_val,spect);
spect(spect == 0) = .000000001*max_val;

% get power in db
 spect=20*log10(abs(spect));

% get power re max in dB 
spect = spect-(max(max(spect)));
%spect = spect - mean(mean(spect));
%spect = spect/(sqrt((sum(sum(spect.*spect)))/(size(spect, 1) * size(spect, 2))));

% truncate at -100 dB
 spect = max(-100, spect);
 
% set index values to range 1-100, with index indicating number of decibels from maximum
% i.e. index = 1 for within 1 dB of max
 idx_spect=max(1,abs(floor(spect)));
