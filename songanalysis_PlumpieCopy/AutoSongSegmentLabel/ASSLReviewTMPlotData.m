function [SpecAxisLimits, LabelAxisLimits, AmpAxisLimits] = ASSLReviewTMPlotData(handles, Time, LogAmplitude)
% This function is called by all plots and this function then calls
% ASSLReviewPlotData


FieldNames = fieldnames(handles);
Index = find(cellfun(@length, strfind(FieldNames, 'ASSL')));

DataStruct = eval(['handles.', FieldNames{Index}]);

if (isfield(DataStruct, 'SyllOnsets'))
    if (isfield(DataStruct, 'SyllLabels'))
        if (get(handles.LoResHiResToggle, 'Value') == 1)
            [SpecAxisLimits, LabelAxisLimits, AmpAxisLimits] = ASSLReviewPlotData(DataStruct.DirName, DataStruct.FileName{DataStruct.FileIndex}, DataStruct.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis, DataStruct.Threshold{DataStruct.FileIndex}, DataStruct.SyllOnsets{DataStruct.FileIndex}, DataStruct.SyllOffsets{DataStruct.FileIndex}, DataStruct.SyllLabels{DataStruct.FileIndex});
        else
            [SpecAxisLimits, LabelAxisLimits, AmpAxisLimits] = ASSLReviewPlotDataLowRes(DataStruct.DirName, DataStruct.FileName{DataStruct.FileIndex}, DataStruct.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis, DataStruct.Threshold{DataStruct.FileIndex}, DataStruct.SyllOnsets{DataStruct.FileIndex}, DataStruct.SyllOffsets{DataStruct.FileIndex}, DataStruct.SyllLabels{DataStruct.FileIndex});
        end
    else
        if (DataStruct.LoResHiRes == 1)
            [SpecAxisLimits, LabelAxisLimits, AmpAxisLimits] = ASSLReviewPlotData(DataStruct.DirName, DataStruct.FileName{DataStruct.FileIndex}, DataStruct.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis, DataStruct.Threshold{DataStruct.FileIndex}, DataStruct.SyllOnsets{DataStruct.FileIndex}, DataStruct.SyllOffsets{DataStruct.FileIndex});
        else
            [SpecAxisLimits, LabelAxisLimits, AmpAxisLimits] = ASSLReviewPlotDataLowRes(DataStruct.DirName, DataStruct.FileName{DataStruct.FileIndex}, DataStruct.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis, DataStruct.Threshold{DataStruct.FileIndex}, DataStruct.SyllOnsets{DataStruct.FileIndex}, DataStruct.SyllOffsets{DataStruct.FileIndex});
        end
    end
else
    if (DataStruct.LoResHiRes == 1)
        [SpecAxisLimits, LabelAxisLimits, AmpAxisLimits] = ASSLReviewPlotData(DataStruct.DirName, DataStruct.FileName{DataStruct.FileIndex}, DataStruct.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis);
    else
        [SpecAxisLimits, LabelAxisLimits, AmpAxisLimits] = ASSLReviewPlotDataLowRes(DataStruct.DirName, DataStruct.FileName{DataStruct.FileIndex}, DataStruct.FileType, Time, LogAmplitude, handles.ReviewSpecAxis, handles.ReviewAmplitudeAxis, handles.ReviewLabelAxis);
    end
end

ASSLAdjustSpectrogram(handles.ASSLReviewTMResults.SpectFloor, handles.ASSLReviewTMResults.SpectCeil, handles.ASSLReviewTMResults.Brightness, 'hot', 'classic', handles.ReviewSpecAxis);