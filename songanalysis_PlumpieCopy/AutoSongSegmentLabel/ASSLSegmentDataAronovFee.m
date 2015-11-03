function [onsets, offsets] = ASSLSegmentDataAronovFee(smooth, Fs, min_int, min_dur, threshold, varargin)

if (nargin > 5)
    BoutOrNot = varargin{1};
else
    BoutOrNot = 0;
end

% If threshold is < median(data), then return empty onsets and offsets as
% this means the threshold is too low. 
% Do this check only if the data being segmented comes from a large file. 
% If it comes from only a bout, then don't apply this.

if (BoutOrNot == 0)
    if (threshold(1) < median(smooth))
        onsets = [];
        offsets = [];
        return;
    end
end

% segment takes smoothed filtered song and returns vectors of note onsets and offsets
% values are in ms 

UpperThresholdCrossings = smooth > threshold(1);
LowerThresholdCrossings = smooth > threshold(2);

%threshold input
notetimes=smooth>threshold(1);

%extract index values for note onsets and offsets
h=[1 -1];
TempU = zeros(size(UpperThresholdCrossings));
TempL = zeros(size(LowerThresholdCrossings));

TempU(find(UpperThresholdCrossings > 0)) = 1;
TempL(find(LowerThresholdCrossings > 0)) = 1;

TransU = conv(h, TempU);
TransL = conv(h, TempL);

OnsetsU = find(TransU > 0);
OffsetsU = find(TransU < 0);

OnsetsL = find(TransL > 0);
OffsetsL = find(TransL < 0);

if (isempty(OnsetsU))
    onsets = [];
    offsets = [];
else
    if (length(OnsetsU) ~= length(OffsetsU))
        disp('number of note onsets and offsets do not match')
    else
        for i = 1:length(OnsetsU),
            Index = find(OnsetsL <= OnsetsU(i), 1, 'last');
            if (isempty(Index))
                onsets(i) = OnsetsU(i);
            else
                onsets(i) = OnsetsL(Index);
            end
            Index = find(OffsetsL >= OffsetsU(i), 1, 'first');
            if (isempty(Index))
                offsets(i) = OffsetsU(i);
            else
                offsets(i) = OffsetsL(Index);
            end
        end
        
        [onsets, OnsetIndices, NewOnsetIndices] = unique(onsets);
        offsets = offsets(OnsetIndices);
            
        %eliminate short intervals
        temp_int=(onsets(2:length(onsets))-offsets(1:length(offsets)-1))*1000/Fs;
        real_ints=temp_int>min_int;
        onsets=[onsets(1); nonzeros(onsets(2:length(onsets)).*real_ints)];
        offsets=[nonzeros(offsets(1:length(offsets)-1).*real_ints); offsets(length(offsets))];

        %eliminate short notes
        temp_dur=(offsets-onsets)*1000/Fs;
        real_durs=temp_dur>min_dur;
        onsets=[nonzeros((onsets).*real_durs)];
        offsets=[nonzeros((offsets).*real_durs)];

        %convert to ms: peculiarities here are to prevent rounding problem
        % if t_ons is simply replaced with onsets, everything gets rounded
        onsets = onsets*1000/Fs;
        offsets = offsets*1000/Fs;

    end
end
