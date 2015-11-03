function [PowSpect, Freq, PowSpect1, Time] = CalculateMultiTaperSpectrogram(Song, Fs, WindowSize, StepSize, BandWidth)

WindowSize = round(WindowSize * Fs/1000);
StepSize = round(StepSize * Fs/1000);

Window = 1:StepSize:(length(Song) - WindowSize);
Increment = 0:1:(WindowSize - 1);

Window = ones(length(Increment),1)*Window;

Increment = Increment(:)*ones(1,size(Window,2));

Window = Window + Increment;

Window = num2cell(Song(Window), 1);

BandWidth = ones(1, size(Window,2))*BandWidth;
BandWidth = num2cell(BandWidth);

Fs = ones(1, size(Window, 2))*Fs;
Fs = num2cell(Fs);

WinLen = ones(1, size(Window,2))*WindowSize;
WinLen = num2cell(WinLen);

[Pxx, f] = cellfun(@pmtm, Window, BandWidth, WinLen, Fs, 'UniformOutput', 0);
% for i = 1:length(Window),
    
PowSpect1 = cell2mat(Pxx);
PowSpect = 10*log10(abs(cell2mat(Pxx)));
Freq = f{1};
Time = linspace(1/Fs{1}, length(Song)/Fs{1}, size(PowSpect, 2));


