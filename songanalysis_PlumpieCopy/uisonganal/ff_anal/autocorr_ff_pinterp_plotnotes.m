function autocorr_ff_pinterp_plotnotes(RawDataDir, batch_in,note, NoteFileDir, ff_low, ff_hi,FileType, PlotOption) % feature added by Raghav as an argument

% SK modified autocorr_ff_pinterp to plot syllables in which FF is
% calculated.

% set color axis for spectrogram
caxis_low = 10;
caxis_hi = 60;

% set higher limit of FF
%ff_hi = 1000; %Hz
%ff_low = 400

%function autocorr_ff_pinterp pulls out all examples of the sound defined by string 'note' 
%uses a batch file ('batch_in') of notefiles and calculates the ff of a 16ms segment of the
%syllable, which is determined by the user
%the user enters the start of the segment by entering either the ms_from_start of the syllable
%or the % in the syllable

%this function uses parts of pick_notes and get_songs to pull out the relevant 16ms segment of the
%syllable of interest, calculates the auto-covariance of the segment, and then
%looks for the distance, in frequency, between the 0th lag and the first peak (does parabolic
%interpolation of the peak given three points)

%us assumes that the file type is 'filt' b/c it requires that notes are already labeled 
%using uisonganal

%also assumes that you are in the subdirectory w/ the data files and the .filt files


clear ffreq
clear ff

k=1;
freq=cell(200,2);
savedata=0;         %does not save the data unless specified
    
    
%make sure note is a string
note=char(note);


%align by the start of the note if align_start==1
align_start=1;


%open batch_file
meta_fid=fopen([batch_in]);
if meta_fid==-1|batch_in==0
        disp('cannot open file')
        disp(batch_in)
end

%what part of the syllable to analyze?
syl_segment=input('1) percent from start,  2) ms from start,  or 3) ms from end?  4) entire syllable ');


if length(syl_segment)==0
    disp('You must specify what part of the syllable to analyze')
%     break
    return;
elseif syl_segment==1
    percent_from_start=input('percent from start?  ');
elseif syl_segment==2
    ms_from_start=input('ms from start?   ');
elseif syl_segment==3
    ms_from_end=input('ms from end?   ');
end    


if (syl_segment < 4)
    sample_size=input('Duration of the segment? (ms)  (default=16ms)  ');
else
    sample_size = [];
end

if isempty(sample_size)
        sample_size=.016;                   %default is 16ms
else sample_size=sample_size/1000;      %convert to seconds
end

half_sample_size=sample_size/2


disp('Sample centered around the time entered')



%save the calculated ffreq?
savedata=input('Do you want to save the values calculated?  1)yes   2) no   ');
if savedata==1
    temp=input('Save as what?   ','s');
else disp ('Calculated frequencies will not be saved.')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% modified by Raghav - added next line
figure_index = 0;
fclose(meta_fid);
FindProperSongFiles(batch_in,note);

meta_fid=fopen(['Actual',batch_in]);

if meta_fid==-1|batch_in==0
        disp('cannot open file')
        disp(batch_in)
end

NoteTimes = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while 1
       %get notefile name
       notefile=fscanf(meta_fid,'%s',1)
       %end when there are no more notefiles
       if isempty(notefile);
           break
       end
       
      
       %if notefile exists, get it
       if exist(fullfile(NoteFileDir, [notefile, '.not.mat']))
           load(fullfile(NoteFileDir, [notefile, '.not.mat']));          %Fs, onsets, offsets and labels are defined
       else disp(['cannot find ',notefile])
       end
       
       %count the number of matches in this file
       labels=makerow(labels);
       matches=findstr(note,labels);   %returns the index for the note in the labels vector
       num_matches=length(matches);
       
       %get soundfile name
       end_file=findstr('.not.mat',notefile);
       rootfile=notefile;
       soundfile=[rootfile,'.filt'];
       
       %get the sound
       for i=1:num_matches  %for all occurrencs of the syllable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           % modified by Raghav - added next seven lines
%            figure_index = figure_index + 1;
%            if (figure_index > 10)
%                 tilefigs;
%                Continue = input('Look at the figures and hit a key when you want to continue');
%                figure_index = 0;
%                c;
%            end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            labels=makerow(labels);
            start_time=onsets(matches(i));      %syl onset
            start_time=start_time/1000;         
            end_time=offsets(matches(i));
            end_time=end_time/1000;             %syl offset
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %  SyllableTime = GetSongTime(notefile);
           % SyllableTime = SyllableTime + start_time/3600;
            SyllableTime = str2double(notefile((end - 13):(end - 8)));
            NoteTimes(end + 1) = SyllableTime;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if (ispc)
                if (RawDataDir(end) ~= '\')
                    RawDataDir(end+1) = '\';
                end
            else
                if (RawDataDir(end) ~= '/')
                    RawDataDir(end+1) = '/';
                end
            end
                 
            %get raw data
            if (strfind(FileType, 'okrank'))
                [rawsong, Fs] = SSAReadOKrankData(RawDataDir, RawDataDir, rootfile, 1);
            else
                disp(rootfile);
                PresentDir = pwd;
                if (strfind(FileType, 'wav'))
                    cd(RawDataDir);
                    [rawsong, Fs] = wavread(rootfile);
                    cd(PresentDir);
                else
                    if (strfind(FileType, 'obs'));
                        [rawsong, Fs] = SSASoundIn(RawDataDir, RawDataDir, rootfile, 'obs0r');
                        rawsong = rawsong * 5/32768;
                    end
                end
            end
%             
%             if (exist(soundfile, 'file'))
%                 [rawsong,Fs]=soundin('',soundfile,'filt');
%             else
%                 [rawsong,Fs]=soundin(RawDataDir,rootfile,FileType);
                rawsong = bandpass(rawsong,Fs,300,8000,'butter');
%            end
            
            %get the desired note
            syllable=rawsong(round(start_time*Fs):round(end_time*Fs));
            
%             syllableindex = 1;
%             for i = 1:length(syllable),
%                 if (mod(i,2) == 1)
%                     tempsyllable(syllableindex) = syllable(i);
%                     syllableindex = syllableindex + 1;
%                 end
%             end
%             syllable = tempsyllable;
%             Fs = Fs/2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Now calculate SAP parameters - added by Raghav from SAM files
            [m_spec_deriv , m_AM, m_FM ,m_Entropy , m_amplitude , m_Freq, m_PitchGoodness , m_Pitch , Pitch_chose , Pitch_weight ]=deriv(rawsong, Fs);
            T = linspace(1, length(rawsong)/Fs, length(m_Entropy));
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
            % plot the note
            if (strfind(PlotOption, 'on'))
                figure
                if (gcf > 30)
                    uiwait(gcf);
                    close all;
                end
            end
%             specgram(syllable,300,Fs,280,250)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
        [spect, freq, time_song] = spectrogram(syllable,300,250,280,Fs,'yaxis');
        idx_spect=scale_spect(spect);  %calculate index array for spectrogram
        f_min = freq(1);
        f_max = freq(length(freq));
        freq_spect = [f_min, f_max];

        t_min = time_song(1);  
        t_max = time_song(end);  
        time_spect = [t_min, t_max];                

        if (strfind(PlotOption, 'on'))
            cm = disp_idx_spect(idx_spect, time_spect, freq_spect, -55, ...
                0, 2.5, 'hot', 'classic');
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
%             spectrogram(syllable,300,250,280,Fs,'yaxis')
            if (strfind(PlotOption, 'on'))
                axis([0 length(syllable)/Fs 250 8000]); 
    %             colormap(flipud(gray)); caxis([caxis_low caxis_hi])
                hold on
            end
            %take a slice through the note
            if syl_segment==1
                note_length=end_time-start_time;        %note_length is in seconds
                temp_start_time=start_time+(note_length*(percent_from_start/100));
                seg_start_time=temp_start_time-half_sample_size;
                seg_end_time=temp_start_time+half_sample_size;
            elseif syl_segment==2                       %(ms from the start)
                temp_start_time=start_time+(ms_from_start/1000);     %(in seconds)
                seg_start_time=temp_start_time-half_sample_size;     %sample centered on time entered
                seg_end_time=(temp_start_time+half_sample_size);     %dur of segment determined by user 
            elseif syl_segment==3
                temp_start_time=end_time-(ms_from_end/1000);     %(in seconds)
                seg_start_time=temp_start_time-half_sample_size;     %sample centered on time entered
                seg_end_time=(temp_start_time+half_sample_size);     %dur of segment determined by user 
            elseif syl_segment == 4 % added this to calculate for the entire syllable
                temp_start_time = start_time;
                seg_start_time = start_time;
                seg_end_time = end_time;
            end  
            
            newstarttime=seg_start_time*Fs;
            newendtime=seg_end_time*Fs;
            note_segment=rawsong(round(newstarttime):round(newendtime));
            
            % draw lines for the period of FF calculation
            FFstart = (seg_start_time-start_time);
            FFend = (seg_end_time-start_time);
            xFFstart = [FFstart, FFstart];
            xFFend = [FFend, FFend];
            y = [250,8000];
            if (strfind(PlotOption, 'on'))
                plot(xFFstart, y, '-r')
                plot(xFFend, y, '-r')
                hold on
            end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% added by Raghav
%             if (strfind(feature,'fm'))
%                 tmp_plot_function = m_FM/90*250*44100/1024;
%                 plot((1:size(m_spec_deriv,1))/1000,tmp_plot_function,'r');            
%             else
%                 if (strfind(feature,'pitch'))
%                     plot((1:size(m_spec_deriv,1))/1000,Pitch_chose,'y.');            
%                     plot((1:size(m_spec_deriv,1))/1000,Pitch_chose*2,'r.');            
%                 else
%                     if (strfind(feature,'pgoodness'))
%                         tmp_plot_function = m_PitchGoodness - min(m_PitchGoodness);
%                         tmp_plot_function = tmp_plot_function/max(tmp_plot_function)*250* 44100/1024;
%                         plot((1:size(m_spec_deriv,1))/1000,tmp_plot_function,'r');            
%                     end
%                 end
%             end
%             
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %analyze the psd of selected song segment
            %nfft=8192;
            %window=8192;
            %[Pxx,freq]=psd(note_segment,nfft,Fs,window);
            %amp=sqrt(Pxx);
            
            
            %calculate the auto-covariance of the song segment
            %window in which it looks for the 1st peak after the 0th lag is 3-100 pts
            [autocorr,lags] =xcov(note_segment);
            %acwin=autocorr(length(note_segment)+3:length(note_segment)+70);  %for ~400-7000 Hz if Fs=32000 Hz
            % if Fs=20000/ use range 3:40  
            acwin=autocorr(length(note_segment)+3:length(note_segment)+round(Fs/ff_low)); 
            
            [max1,loc]=max(acwin);
            if loc==1 | loc==length(acwin)
                peak=loc;   %parabolic interpolation req at least 3 points
            else
%                 peak = loc;
                peak=pinterp([loc-1;loc;loc+1],[acwin(loc-1);acwin(loc);acwin(loc+1)]);
            end     %peak values are real number
            period=peak+2;   %using window from 3rd-100th point after peak;
                            %if peak is the 3rd point,peak=1; so period=peak+2                
            ff=Fs/period;
            %clip=autocorr(length(note_segment):end);        %take half b/c autocorr is 2X
                                                            %the size of the segment
            
           % SK modefied the follwoing part to limit highest ff value
            if ff > ff_hi
                   while 1
                       q = loc+1;
                       while q
                           if acwin(q-1)<acwin(q) & acwin(q) > acwin(q+1) 
                               loc3 = q;
                               break
                           end
                           q = q+1;
                       end
                       %[max1,loc2]=max(acwin(loc+5:length(acwin)));
                       %loc3 = loc2+loc+5;
                       peak = loc3;
                       peak=pinterp([loc3-1;loc3;loc3+1],[acwin(loc3-1);acwin(loc3);acwin(loc3+1)]);
                       period=peak+2;                               
                       ff=Fs/period;
                       if ff <= ff_hi
                           break
                       end
                       loc = loc3;
                   end
               end
           ff
           
           % Draw a line indicating the ff value
           x = linspace(FFstart,FFend,50);
           if (strfind(PlotOption, 'on'))
               plot(x, ff*ones(size(x)), 'g', 'LineWidth', 2)
           end
           
%            [m_spec_deriv , m_AM, m_FM ,m_Entropy , m_amplitude , m_Freq, m_PitchGoodness , m_Pitch , Pitch_chose , Pitch_weight ]=segment_data(note_segment,Fs);
           % title for the figure
%           title( [soundfile,',  #',(int2str(i)), ',  ff = ', (num2str(ff)),', ff = ', num2str(mean(Pitch_chose)*2)])
           if (strfind(PlotOption, 'on'))           
                title( [soundfile,',  #',(int2str(i)), ',  ff = ', (num2str(ff))])
           end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            figure;
%            plot(lags,autocorr,'b');
%            hold on;
%            plot(lags(length(note_segment)+3:length(note_segment)+round(Fs/ff_low)),acwin,'r');
%            axis([-50 (lags(length(note_segment) + round(Fs/ff_low)) + 50) min(autocorr) max(autocorr)]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
 %           plot(lags(loc + length(note_segment) + 2),max1,'gs');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            

           %save values in a cell array w/ 2 elements:  songname and fundfreq
            ffreq{k,1}=soundfile;
            ffreq{k,2}=ff;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% added by Raghav
            ffreq{k,4} = length(syllable)/Fs;
            ffreq{k,5} = SyllableTime;
            StartIndex = find((T>=seg_start_time), 1, 'first');
            EndIndex = find((T>seg_end_time), 1, 'first');
            ffreq{k,6} = mean(m_AM(StartIndex:EndIndex));
            ffreq{k,7} = mean(m_Entropy(StartIndex:EndIndex));
            ffreq{k,8} = mean(m_Freq(StartIndex:EndIndex));
            ffreq{k,9} = mean(Pitch_chose(StartIndex:EndIndex));
            ffreq{k,10} = mean(m_FM(StartIndex:EndIndex));
            ffreq{k,11} = mean(m_amplitude(StartIndex:EndIndex));
            ffreq{k,12} = mean(m_Freq(StartIndex:EndIndex));
            ffreq{k,13} = mean(m_PitchGoodness(StartIndex:EndIndex));
            ffreq{k,14} = start_time;
            ffreq{k,15} = end_time;
            ffreq{k,16} = matches(i); % the actual index in the variable labels in the note file
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %ffreq{k,3}=peak;
            k=k+1;
         
            if savedata==1                      %save filename, ff, sample duration and place in syllable to mat file
                jj=['',temp];
                if syl_segment==1
                save (jj,'ffreq','percent_from_start','sample_size','note','Fs')    
                elseif syl_segment==2
                save (jj,'ffreq','ms_from_start','sample_size','note','Fs')     
                elseif syl_segment==3
                save (jj,'ffreq','ms_from_end','sample_size','note','Fs')    
                elseif syl_segment==4
                save (jj,'ffreq', 'note','Fs')    
                end
            end
                
%             end
         
%         end     
            
           
    end %for loop
    
end     %while loop

fclose(meta_fid);

% end

% display the results
[ffreq{:,2}]'

% plot the results
plot_notes4DS_UDS2(' ', ' ', [ffreq{:,2}]); 
axis auto;
figure;
plot([ffreq{:,5}],[ffreq{:,2}],'r.');
axis auto;
