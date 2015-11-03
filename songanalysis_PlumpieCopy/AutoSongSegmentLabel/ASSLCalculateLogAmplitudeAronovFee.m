function [LogAmplitude] = ASSLCalculateLogAmplitudeAronovFee(RawData, Fs, Time, FFTWinSize, FFTWinOverlap, varargin)

% WinSize = round(FFTWinSize * Fs/1000);
% WinOverlap = round(WinSize * FFTWinOverlap);
% [S, F, T, P] = spectrogram(RawData, hamming(WinSize), WinOverlap, WinSize, Fs);
% Freq = find((F >= 300) & (F <= 8000));
% LogAmplitude = 10*log10(sum((S(Freq,:)).*conj((S(Freq,:)))));
% LogAmplitude = spline(T, LogAmplitude, Time);

if (nargin <= 5)
    F_High = 1000; % high pass filter cut-off
    F_Low = 4000; % low pass filter cut-off
else
    F_High = varargin{1}; % high pass filter cut-off
    F_Low = varargin{2}; % low pass filter cut-off
end
FilterForSong = fir1(80, [F_High*2/Fs F_Low*2/Fs], 'bandpass');
FiltSong = filtfilt(FilterForSong, 1, RawData);

SmoothWinSize = FFTWinSize/1000;
 
Window = ones(round(SmoothWinSize*Fs), 1);
Window = Window/sum(Window);
smooth = 10*log10(conv(FiltSong.*FiltSong, Window, 'same'));

LogAmplitude = smooth;

if (size(LogAmplitude, 1) > size(LogAmplitude, 2))
    LogAmplitude = LogAmplitude';
end