function varargout = ASSLAnalyzeSyllables(varargin)
% ASSLANALYZESYLLABLES M-file for ASSLAnalyzeSyllables.fig
%      ASSLANALYZESYLLABLES, by itself, creates a new ASSLANALYZESYLLABLES or raises the existing
%      singleton*.
%
%      H = ASSLANALYZESYLLABLES returns the handle to a new ASSLANALYZESYLLABLES or the handle to
%      the existing singleton*.
%
%      ASSLANALYZESYLLABLES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ASSLANALYZESYLLABLES.M with the given input arguments.
%
%      ASSLANALYZESYLLABLES('Property','Value',...) creates a new ASSLANALYZESYLLABLES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ASSLAnalyzeSyllables_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ASSLAnalyzeSyllables_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ASSLAnalyzeSyllables

% Last Modified by GUIDE v2.5 16-Oct-2015 23:49:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ASSLAnalyzeSyllables_OpeningFcn, ...
                   'gui_OutputFcn',  @ASSLAnalyzeSyllables_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ASSLAnalyzeSyllables is made visible.
function ASSLAnalyzeSyllables_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ASSLAnalyzeSyllables (see VARARGIN)

% Choose default command line output for ASSLAnalyzeSyllables
handles.output = hObject;

if (length(varargin) > 0)
    handles.DataStruct = varargin{1};
end

set(handles.XListBox, 'String', handles.DataStruct.ToBeUsedFeatures);
set(handles.XListBox, 'Value', 1);
set(handles.YListBox, 'String', handles.DataStruct.ToBeUsedFeatures);
set(handles.YListBox, 'Value', 1);

[handles] = RePlotSyllFeatures(handles);

handles.ASSLAS.BoutDefinitions = [{'Treat each new file as a bout'}; {'Use specified inter-bout interval'}];
handles.ASSLAS.BoutDefinitionChoice = 1;
set(handles.BoutDefinitionMenu, 'String', handles.ASSLAS.BoutDefinitions);
set(handles.BoutDefinitionMenu, 'Value', handles.ASSLAS.BoutDefinitionChoice);

handles.ASSLAS.IndividualFeatPlotOptions = [{'Plot individual traces'}; {'Plot mean + std.dev'}; {'Plot mean + std. error'}];
handles.ASSLAS.IndividualFeatPlotChoice = 1;
set(handles.IndividualFeatPlotChoiceMenu, 'String', handles.ASSLAS.IndividualFeatPlotOptions);
set(handles.IndividualFeatPlotChoiceMenu, 'Value', handles.ASSLAS.IndividualFeatPlotChoice);

handles.ASSLAS.InterBoutInterval = 2;
set(handles.InterBoutIntervalEdit, 'String', num2str(handles.ASSLAS.InterBoutInterval));

[handles] = ReAssignSyllDetails(handles);
 
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ASSLAnalyzeSyllables wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ASSLAnalyzeSyllables_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in XListBox.
function XListBox_Callback(hObject, eventdata, handles)
% hObject    handle to XListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns XListBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from XListBox
handles.ASSLAS.XVal = get(hObject, 'Value');
SyllsToPlot = get(handles.SyllableListBox, 'Value');

for i = 1:length(SyllsToPlot),
    if (SyllsToPlot(i) == 1)
        ASSLASPlotData(handles, 0, [0.5 0.5 0.5], '.', 3, handles.ASSLFeaturePlotAxis);
    else
        if (i == 1)
            ClearAxis = 1;
        else
            ClearAxis = 0;
        end
        Indices = find(handles.DataStruct.SyllIndexLabels == handles.ASSLAS.UniqueSylls(SyllsToPlot(i) - 1));
        ASSLASPlotData(handles, 0, handles.ASSLAS.Colors(handles.ASSLAS.UniqueSyllColors(SyllsToPlot(i) - 1)), handles.ASSLAS.Symbols(handles.ASSLAS.UniqueSyllSymbols(SyllsToPlot(i) - 1)), 4, handles.ASSLFeaturePlotAxis, ClearAxis, Indices);
    end
end

CurrSyll = get(handles.CurrSyllListBox, 'Value');

PrevNextSyll = get(handles.PrevNextSyllListBox, 'Value');
PrevNext = get(handles.PrevNextSyllMenu, 'Value');

for i = 1:length(PrevNextSyll),
    if (PrevNext == 1)
        Indices = strfind(handles.DataStruct.SyllIndexLabels', [handles.ASSLAS.UniqueSylls(PrevNextSyll(i)), handles.ASSLAS.UniqueSylls(CurrSyll)]);
        Indices = Indices + 1;
    else
        Indices = strfind(handles.DataStruct.SyllIndexLabels', [handles.ASSLAS.UniqueSylls(CurrSyll), handles.ASSLAS.UniqueSylls(PrevNextSyll(i))]);
    end

    if (i == 1)
        ClearAxis = 1;
    else
        ClearAxis = 0;
    end
    ASSLASPlotData(handles, 1, handles.ASSLAS.Colors(handles.ASSLAS.UniqueSyllColors(PrevNextSyll(i))), handles.ASSLAS.Symbols(handles.ASSLAS.UniqueSyllSymbols(PrevNextSyll(i))), 4, handles.ASSLNextSyllAxis, ClearAxis, Indices);
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function XListBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in YListBox.
function YListBox_Callback(hObject, eventdata, handles)
% hObject    handle to YListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns YListBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from YListBox

handles.ASSLAS.YVal = get(hObject, 'Value');
SyllsToPlot = get(handles.SyllableListBox, 'Value');

for i = 1:length(SyllsToPlot),
    if (SyllsToPlot(i) == 1)
        ASSLASPlotData(handles, 0, [0.5 0.5 0.5], '.', 3, handles.ASSLFeaturePlotAxis);
    else
        if (i == 1)
            ClearAxis = 1;
        else
            ClearAxis = 0;
        end
        Indices = find(handles.DataStruct.SyllIndexLabels == handles.ASSLAS.UniqueSylls(SyllsToPlot(i) - 1));
        ASSLASPlotData(handles, 0, handles.ASSLAS.Colors(handles.ASSLAS.UniqueSyllColors(SyllsToPlot(i) - 1)), handles.ASSLAS.Symbols(handles.ASSLAS.UniqueSyllSymbols(SyllsToPlot(i) - 1)), 4, handles.ASSLFeaturePlotAxis, ClearAxis, Indices);
    end
end

CurrSyll = get(handles.CurrSyllListBox, 'Value');

PrevNextSyll = get(handles.PrevNextSyllListBox, 'Value');
PrevNext = get(handles.PrevNextSyllMenu, 'Value');

for i = 1:length(PrevNextSyll),
    if (PrevNext == 1)
        Indices = strfind(handles.DataStruct.SyllIndexLabels', [handles.ASSLAS.UniqueSylls(PrevNextSyll(i)), handles.ASSLAS.UniqueSylls(CurrSyll)]);
        Indices = Indices + 1;
    else
        Indices = strfind(handles.DataStruct.SyllIndexLabels', [handles.ASSLAS.UniqueSylls(CurrSyll), handles.ASSLAS.UniqueSylls(PrevNextSyll(i))]);
    end

    if (i == 1)
        ClearAxis = 1;
    else
        ClearAxis = 0;
    end
    ASSLASPlotData(handles, 1, handles.ASSLAS.Colors(handles.ASSLAS.UniqueSyllColors(PrevNextSyll(i))), handles.ASSLAS.Symbols(handles.ASSLAS.UniqueSyllSymbols(PrevNextSyll(i))), 4, handles.ASSLNextSyllAxis, ClearAxis, Indices);
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function YListBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in CurrSyllListBox.
function CurrSyllListBox_Callback(hObject, eventdata, handles)
% hObject    handle to CurrSyllListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns CurrSyllListBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CurrSyllListBox
CurrSyll = get(handles.CurrSyllListBox, 'Value');

PrevNextSyll = get(handles.PrevNextSyllListBox, 'Value');
PrevNext = get(handles.PrevNextSyllMenu, 'Value');

for i = 1:length(PrevNextSyll),
    if (PrevNext == 1)
        Indices = strfind(handles.DataStruct.SyllIndexLabels', [handles.ASSLAS.UniqueSylls(PrevNextSyll(i)), handles.ASSLAS.UniqueSylls(CurrSyll)]);
        Indices = Indices + 1;
    else
        Indices = strfind(handles.DataStruct.SyllIndexLabels', [handles.ASSLAS.UniqueSylls(CurrSyll), handles.ASSLAS.UniqueSylls(PrevNextSyll(i))]);
    end

    if (i == 1)
        ClearAxis = 1;
    else
        ClearAxis = 0;
    end
    ASSLASPlotData(handles, 1, handles.ASSLAS.Colors(handles.ASSLAS.UniqueSyllColors(PrevNextSyll(i))), handles.ASSLAS.Symbols(handles.ASSLAS.UniqueSyllSymbols(PrevNextSyll(i))), 4, handles.ASSLNextSyllAxis, ClearAxis, Indices);
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function CurrSyllListBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurrSyllListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in CurrSyllColorButton.
function CurrSyllColorButton_Callback(hObject, eventdata, handles)
% hObject    handle to CurrSyllColorButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns CurrSyllColorButton contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CurrSyllColorButton


% --- Executes during object creation, after setting all properties.
function CurrSyllColorButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurrSyllColorButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

Temp(:,:,1) = ones(10,100);
Temp(:,:,2) = zeros(10,100);
Temp(:,:,3) = zeros(10,100);

set(hObject, 'CData', Temp);

% --- Executes on selection change in PrevNextSyllListBox.
function PrevNextSyllListBox_Callback(hObject, eventdata, handles)
% hObject    handle to PrevNextSyllListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PrevNextSyllListBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PrevNextSyllListBox
CurrSyll = get(handles.CurrSyllListBox, 'Value');

PrevNextSyll = get(handles.PrevNextSyllListBox, 'Value');
PrevNext = get(handles.PrevNextSyllMenu, 'Value');

for i = 1:length(PrevNextSyll),
    if (PrevNext == 1)
        Indices = strfind(handles.DataStruct.SyllIndexLabels', [handles.ASSLAS.UniqueSylls(PrevNextSyll(i)), handles.ASSLAS.UniqueSylls(CurrSyll)]);
        Indices = Indices + 1;
    else
        Indices = strfind(handles.DataStruct.SyllIndexLabels', [handles.ASSLAS.UniqueSylls(CurrSyll), handles.ASSLAS.UniqueSylls(PrevNextSyll(i))]);
    end

    if (i == 1)
        ClearAxis = 1;
    else
        ClearAxis = 0;
    end
    ASSLASPlotData(handles, 1, handles.ASSLAS.Colors(handles.ASSLAS.UniqueSyllColors(PrevNextSyll(i))), handles.ASSLAS.Symbols(handles.ASSLAS.UniqueSyllSymbols(PrevNextSyll(i))), 4, handles.ASSLNextSyllAxis, ClearAxis, Indices);
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function PrevNextSyllListBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PrevNextSyllListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PrevNextSyllColorButton.
function PrevNextSyllColorButton_Callback(hObject, eventdata, handles)
% hObject    handle to PrevNextSyllColorButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Temp(:,:,1) = zeros(10,100);
Temp(:,:,2) = ones(10,100);
Temp(:,:,3) = zeros(10,100);

set(hObject, 'CData', Temp);

% --- Executes on selection change in SyllableListBox.
function SyllableListBox_Callback(hObject, eventdata, handles)
% hObject    handle to SyllableListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SyllableListBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SyllableListBox
SyllsToPlot = get(hObject, 'Value');

for i = 1:length(SyllsToPlot),
    if (SyllsToPlot(i) == 1)
        ASSLASPlotData(handles, 0, [0.5 0.5 0.5], '.', 3, handles.ASSLFeaturePlotAxis);
    else
        if (i == 1)
            ClearAxis = 1;
        else
            ClearAxis = 0;
        end
        Indices = find(handles.DataStruct.SyllIndexLabels == handles.ASSLAS.UniqueSylls(SyllsToPlot(i) - 1));
        ASSLASPlotData(handles, 0, handles.ASSLAS.Colors(handles.ASSLAS.UniqueSyllColors(SyllsToPlot(i) - 1)), handles.ASSLAS.Symbols(handles.ASSLAS.UniqueSyllSymbols(SyllsToPlot(i) - 1)), 4, handles.ASSLFeaturePlotAxis, ClearAxis, Indices);
    end
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function SyllableListBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SyllableListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PrevNextSyllMenu.
function PrevNextSyllMenu_Callback(hObject, eventdata, handles)
% hObject    handle to PrevNextSyllMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PrevNextSyllMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PrevNextSyllMenu


% --- Executes during object creation, after setting all properties.
function PrevNextSyllMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PrevNextSyllMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CalSyllTransProbButton.
function CalSyllTransProbButton_Callback(hObject, eventdata, handles)
% hObject    handle to CalSyllTransProbButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

AllLabels = [];
if (strfind(handles.ASSLAS.BoutDefinitions{handles.ASSLAS.BoutDefinitionChoice}, 'Treat each new file as a bout'))
    for i = 1:length(handles.DataStruct.SyllLabels),
        AllLabels = [AllLabels 'Q', handles.DataStruct.SyllLabels{i}, 'q'];
    end
else
    if (strfind(handles.ASSLAS.BoutDefinitions{handles.ASSLAS.BoutDefinitionChoice}, 'Use specified inter-bout interval'))
        [TempSyllTransitionProb, AllLabels] = CalculateSyllTransitionProbabilities(handles.DataStruct.FileListName, handles.DataStruct.NoteFileDirName, handles.ASSLAS.InterBoutInterval);
    end
end

UniqueLabels = unique(AllLabels);

Index = 0;
for i = 1:length(UniqueLabels),
    ColNames{i} = UniqueLabels(i);
    if (UniqueLabels(i) ~= 'q')
        Index = Index + 1;
        RowNames{Index} = UniqueLabels(i);
        Matches = find(AllLabels == UniqueLabels(i));
        for j = 1:length(UniqueLabels),
            SyllTransitionProb(Index, j) = length(find(AllLabels(Matches + 1) == UniqueLabels(j)))/length(Matches);
        end
    end
end

SyllTransitionProb(find(SyllTransitionProb < 0.001)) = 0;

handles.ASSLAS.SyllTransitionProb = SyllTransitionProb;
handles.ASSLAS.AllLabels = AllLabels;

ColWidth = {50};
SyllTransProbFigure = figure('Position', [200 200 (ColWidth{1}*length(UniqueLabels) + 100) (15*(length(UniqueLabels)-1) + 100)]);
SyllTransTable = uitable('Parent', SyllTransProbFigure, 'Data', SyllTransitionProb, 'ColumnName', ColNames, 'RowName', RowNames, 'Position', [20 20 (ColWidth{1}*length(UniqueLabels) + 60) (15*(length(UniqueLabels) - 1) + 60)]); 
set(SyllTransTable, 'ColumnWidth', ColWidth);
title('Syllable transition probabilities', 'FontWeight', 'bold', 'FontSize', 12);
set(gca, 'XTick', []);

figure;
imagesc(handles.ASSLAS.SyllTransitionProb);
set(gca, 'XTick', [1:1:length(UniqueLabels)], 'XTickLabel', num2cell(UniqueLabels));
set(gca, 'YTick', [1:1:length(UniqueLabels)], 'YTickLabel', num2cell(UniqueLabels));
colorbar;
guidata(hObject, handles);

% --- Executes on button press in LocateSyllOutliersButton.
function LocateSyllOutliersButton_Callback(hObject, eventdata, handles)
% hObject    handle to LocateSyllOutliersButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in BoutDefinitionMenu.
function BoutDefinitionMenu_Callback(hObject, eventdata, handles)
% hObject    handle to BoutDefinitionMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns BoutDefinitionMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from BoutDefinitionMenu
handles.ASSLAS.BoutDefinitionChoice = get(hObject, 'Value');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function BoutDefinitionMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BoutDefinitionMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function InterBoutIntervalEdit_Callback(hObject, eventdata, handles)
% hObject    handle to InterBoutIntervalEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of InterBoutIntervalEdit as text
%        str2double(get(hObject,'String')) returns contents of InterBoutIntervalEdit as a double


% --- Executes during object creation, after setting all properties.
function InterBoutIntervalEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InterBoutIntervalEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in IndividualFeatPlotChoiceMenu.
function IndividualFeatPlotChoiceMenu_Callback(hObject, eventdata, handles)
% hObject    handle to IndividualFeatPlotChoiceMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns IndividualFeatPlotChoiceMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from IndividualFeatPlotChoiceMenu


% --- Executes during object creation, after setting all properties.
function IndividualFeatPlotChoiceMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IndividualFeatPlotChoiceMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------
function uitoggletool1_OnCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Cursor = datacursormode;
set(Cursor,'UpdateFcn',{@datatips,Cursor,handles});


function output_txt  = datatips(obj,event_obj,Cursor,handles)
% Display an observation's Y-data and label for a data tip
% obj          Currently not used (empty)
% event_obj    Handle to event object


dcs=Cursor.DataCursors;
pos = get(dcs(1),'Position');   %Position of 1st cursor

%Num=find(handles.DataStruct.FeatValues(:,handles.ASSLAS.XVal)==pos(1) & handles.DataStruct.FeatValues(:,handles.ASSLAS.YVal)==pos(2));
% Changed find to knnsearch for better performance - Raghav 27th October
% 2014
Num = knnsearch(handles.DataStruct.FeatValues(:,[handles.ASSLAS.XVal handles.ASSLAS.YVal]), pos(1:2));

Filenum=handles.DataStruct.SyllIndices(Num,1);
Syllnum=handles.DataStruct.SyllIndices(Num,2);
Filename=handles.DataStruct.FileName{Filenum};

% Added code to plot log amplitude and spectrogram of chosen syllable
[RawData, Fs] = ASSLGetRawData(handles.DataStruct.DirName, Filename, handles.DataStruct.FileType, 1);
SyllOnset = (handles.DataStruct.SyllOnsets{Filenum}(Syllnum) - 10) * Fs/1000; % take 10ms before syll onset and convert to index
if (SyllOnset < 1)
    SyllOnset = 1;
end
if (SyllOnset > length(RawData))
    SyllOnset = length(RawData);
end

SyllOffset = (handles.DataStruct.SyllOffsets{Filenum}(Syllnum) + 10) * Fs/1000; % take 10ms after syll offset and convert to index
if (SyllOffset < 1)
    SyllOffset = 1;
end
if (SyllOffset > length(RawData))
    SyllOffset = length(RawData);
end

if ((SyllOffset - SyllOnset) > (0.01 * Fs))
    axes(handles.ASSLFeaturePlotAxis);
    hold on;
    if (isfield(handles, 'SyllOutline'))
        if (ishandle(handles.SyllOutline))
            delete(handles.SyllOutline);
        end
        handles = rmfield(handles, 'SyllOutline');
    end
    handles.SyllOutline = plot(x, y, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
    
    RawData = RawData(SyllOnset:SyllOffset);
    cla(handles.SyllSpect);
    axes(handles.SyllSpect);
    PlotSpectrogramInAxis_SongVar(RawData, (1:1:length(RawData))/Fs, Fs, gca);
    axis([0 0.300 300 8000]);
    
    LogAmplitude = ASSLCalculateLogAmplitudeAronovFee(RawData, Fs);
    axes(handles.SyllAmpWF);
    plot((1:1:length(RawData))*1000/Fs, LogAmplitude, 'k');
    axis tight;
    Temp = axis;
    axis([0 300 Temp(3:4)]);
    set(gca, 'FontSize', 10, 'FontWeight', 'bold');
    xlabel('Time (ms)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Log Amplitude (dB)', 'FontSize', 12, 'FontWeight', 'bold');
end

output_txt{1} = ['X: ', num2str(pos(1))];
output_txt{2} = ['Y: ', num2str(pos(2))]; %this is the text next to the cursor
output_txt{3}=['FileNo. ', num2str(Filenum)];
output_txt{4}=['FileName ', [Filename]];
output_txt{5}=['SyllNo. ', num2str(Syllnum)];
guidata(hObject, handles);


% --------------------------------------------------------------------
function uitoggletool2_OnCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function uitoggletool3_OnCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in PickSyllableButton.
function PickSyllableButton_Callback(hObject, eventdata, handles)
% hObject    handle to PickSyllableButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get syllable
axes(handles.ASSLFeaturePlotAxis);
[x, y, button] = ginput(1);

% First find out what syllables are currently being plotted
SyllsToPlot = get(handles.SyllableListBox, 'Value');
Indices = [];

if (SyllsToPlot(1) == 1)
    Indices = (1:1:length(handles.DataStruct.SyllIndexLabels));
    Indices = Indices(:);
else
    for i = 1:length(SyllsToPlot),
        TempIndices = find(handles.DataStruct.SyllIndexLabels == handles.ASSLAS.UniqueSylls(SyllsToPlot(i) - 1));
        Indices = [Indices; TempIndices(:)];
    end
end

x = (x - mean(handles.DataStruct.FeatValues(Indices, handles.ASSLAS.XVal)))/std(handles.DataStruct.FeatValues(Indices, handles.ASSLAS.XVal));
y = (y - mean(handles.DataStruct.FeatValues(Indices, handles.ASSLAS.YVal)))/std(handles.DataStruct.FeatValues(Indices, handles.ASSLAS.YVal));

Num = knnsearch(zscore(handles.DataStruct.FeatValues(Indices,[handles.ASSLAS.XVal handles.ASSLAS.YVal])), [x y]);
Num = Indices(Num);
%TempDistances = pdist2(zscore(handles.DataStruct.FeatValues(:,[handles.ASSLAS.XVal handles.ASSLAS.YVal])), [x y]);
%[MinDist, MinDist_Index] = min(TempDistances);
%Num = MinDist_Index;

x = handles.DataStruct.FeatValues(Num, handles.ASSLAS.XVal);
y = handles.DataStruct.FeatValues(Num, handles.ASSLAS.YVal);

Filenum=handles.DataStruct.SyllIndices(Num,1);
Syllnum=handles.DataStruct.SyllIndices(Num,2);
Filename=handles.DataStruct.FileName{Filenum};

% Added code to plot log amplitude and spectrogram of chosen syllable
[RawData, Fs] = ASSLGetRawData(handles.DataStruct.DirName, Filename, handles.DataStruct.FileType, 1);
SyllOnset = round((handles.DataStruct.SyllOnsets{Filenum}(Syllnum) - 10) * Fs/1000); % take 10ms before syll onset and convert to index
if (SyllOnset < 1)
    SyllOnset = 1;
end
if (SyllOnset > length(RawData))
    SyllOnset = length(RawData);
end

SyllOffset = round((handles.DataStruct.SyllOffsets{Filenum}(Syllnum) + 10) * Fs/1000); % take 10ms after syll offset and convert to index
if (SyllOffset < 1)
    SyllOffset = 1;
end
if (SyllOffset > length(RawData))
    SyllOffset = length(RawData);
end

if ((SyllOffset - SyllOnset) > (0.01 * Fs))
    axes(handles.ASSLFeaturePlotAxis);
    hold on;
    if (isfield(handles, 'SyllOutline'))
        if (ishandle(handles.SyllOutline))
            delete(handles.SyllOutline);
        end
        handles = rmfield(handles, 'SyllOutline');
    end
    handles.SyllOutline = plot(x, y, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
    
    RawData = RawData(SyllOnset:SyllOffset);
    cla(handles.SyllSpect);
    axes(handles.SyllSpect);
    PlotSpectrogramInAxis_SongVar(RawData, (1:1:length(RawData))/Fs, Fs, gca);
    axis([0 0.300 300 8000]);
    
    
    LogAmplitude = ASSLCalculateLogAmplitudeAronovFee(RawData, Fs, (1:1:length(RawData))/Fs, handles.DataStruct.FFTWinSizeSegmenting, handles.DataStruct.FFTWinOverlapSegmenting, handles.DataStruct.HiPassCutOff, handles.DataStruct.LoPassCutOff);
    axes(handles.SyllAmpWF);
    plot((1:1:length(RawData))*1000/Fs, LogAmplitude, 'k');
    axis tight;
    Temp = axis;
    axis([0 300 Temp(3:4)]);
    set(gca, 'FontSize', 10, 'FontWeight', 'bold');
    xlabel('Time (ms)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Log Amplitude (dB)', 'FontSize', 12, 'FontWeight', 'bold');
end

output_txt{1} = ['X: ', num2str(x)];
output_txt{2} = ['Y: ', num2str(y)]; %this is the text next to the cursor
output_txt{3}=['FileNo. ', num2str(Filenum)];
output_txt{4}=['FileName ', [Filename]];
output_txt{5}=['SyllNo. ', num2str(Syllnum)];
set(handles.SyllInfoText, 'String', output_txt);
guidata(hObject, handles);


% --- Executes on button press in MergeSyllsButton.
function MergeSyllsButton_Callback(hObject, eventdata, handles)
% hObject    handle to MergeSyllsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SyllsToMerge = inputdlg('Enter the syllables that need to be merged, separated by commas', 'Syllables to merge');
SyllsToMerge = cell2mat(textscan(SyllsToMerge{1}, '%c', 'DeLimiter', ','));

SyllIndices = [];
for i = 1:length(SyllsToMerge),
    TempIndices = find(handles.DataStruct.SyllIndexLabels == SyllsToMerge(i));
    SyllIndices = [SyllIndices; TempIndices(:)];
end

if (~isempty(SyllIndices))
    handles.DataStruct.SyllIndexLabels(SyllIndices) = SyllsToMerge(1);
end

[handles] = RePlotSyllFeatures(handles);
[handles] = ReAssignSyllDetails(handles);

guidata(hObject, handles);
disp('Finished merging syllables');

% --- Executes on button press in ChangeSyllLabelsButton.
function ChangeSyllLabelsButton_Callback(hObject, eventdata, handles)
% hObject    handle to ChangeSyllLabelsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

SyllsToChange = inputdlg('Enter the syllable that needs to be changed', 'Syllables to change');
SyllsToChange = SyllsToChange{1};

NewSyllLabel = inputdlg('Enter the new syllable label', 'New syllable label');
NewSyllLabel = NewSyllLabel{1};

SyllIndices = find(handles.DataStruct.SyllIndexLabels == SyllsToChange);

if (~isempty(SyllIndices))
    handles.DataStruct.SyllIndexLabels(SyllIndices) = NewSyllLabel;
end

[handles] = RePlotSyllFeatures(handles);
[handles] = ReAssignSyllDetails(handles);

guidata(hObject, handles);
disp('Finished merging syllables');

% --- Executes on button press in ReturnSyllDataButton.
function ReturnSyllDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to ReturnSyllDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ASSLMainWindow = findobj('Name', 'AutoSongSegmentLabel');
if (length(ASSLMainWindow) > 0)
    ASSLData = guidata(ASSLMainWindow);
    ASSLData.ASSL.SyllLabels = handles.DataStruct.SyllLabels;
    ASSLData.ASSL.SyllOnsets = handles.DataStruct.SyllOnsets;
    ASSLData.ASSL.SyllOffsets = handles.DataStruct.SyllOffsets;
    ASSLData.ASSL.SyllIndexLabels = handles.DataStruct.SyllIndexLabels;
    guidata(ASSLMainWindow, ASSLData);
    msgbox('Returned edit syllable details to Auto Song Segment Label');
end

% --- Executes on button press in RenameSelectSyllablesButton.
function RenameSelectSyllablesButton_Callback(hObject, eventdata, handles)
% hObject    handle to RenameSelectSyllablesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.ASSLFeaturePlotAxis);
Flag = 1;

Index = 1;
while (Flag == 1)
    if (Index > 2)
        ContourLine(Index) = plot(x(Index-2:Index-1), y(Index-2:Index-1), 'y', 'LineWidth', 2);
    end
    [Tempx, Tempy, button] = ginput(1);
    if (isempty(button))
        Flag = 0;
    else
        if (button == 3)
            Flag = 0;
        else
            x(Index) = Tempx;
            y(Index) = Tempy;
        end
    end
    Index = Index + 1;
end
ContourLine(Index+1) = plot([x(end) x(1)], [y(end) y(1)], 'y', 'LineWidth', 2);

% Now check if any of the limits have gone out of the plot axis
TempAxis = axis;
x(find(x < TempAxis(1))) = TempAxis(1);
x(find(x > TempAxis(2))) = TempAxis(2);

y(find(y < TempAxis(3))) = TempAxis(3);
y(find(y > TempAxis(4))) = TempAxis(4);

% Now find points inside the polygon
% First find out what syllables are currently being plotted
SyllsToPlot = get(handles.SyllableListBox, 'Value');
Indices = [];

if (SyllsToPlot(1) == 1)
    Indices = (1:1:length(handles.DataStruct.SyllIndexLabels));
    Indices = Indices(:);
else
    for i = 1:length(SyllsToPlot),
        TempIndices = find(handles.DataStruct.SyllIndexLabels == handles.ASSLAS.UniqueSylls(SyllsToPlot(i) - 1));
        Indices = [Indices; TempIndices(:)];
    end
end

Sylls = inpolygon(handles.DataStruct.FeatValues(Indices, handles.ASSLAS.XVal), handles.DataStruct.FeatValues(Indices, handles.ASSLAS.YVal), x, y);
SyllsPlot = plot(handles.DataStruct.FeatValues(Indices(Sylls), handles.ASSLAS.XVal), handles.DataStruct.FeatValues(Indices(Sylls), handles.ASSLAS.YVal), 'yo', 'LineWidth', 2);
uiwait(gcf, 2);

NewSyllLabel = inputdlg('Enter the new syllable label', 'New syllable label');
NewSyllLabel = NewSyllLabel{1};

if (~isempty(Sylls))
    handles.DataStruct.SyllIndexLabels(Indices(Sylls)) = NewSyllLabel;
end

for i = 1:length(ContourLine),
    if (ContourLine(i) ~= 0)
        delete(ContourLine(i));
    end
end
delete(SyllsPlot);

[handles] = RePlotSyllFeatures(handles);
[handles] = ReAssignSyllDetails(handles);

guidata(hObject, handles);
disp('Finished renaming select syllables');


% --- Executes on button press in DeleteSelectSyllablesButton.
function DeleteSelectSyllablesButton_Callback(hObject, eventdata, handles)
% hObject    handle to DeleteSelectSyllablesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.ASSLFeaturePlotAxis);
Flag = 1;

Index = 1;
while (Flag == 1)
    if (Index > 2)
        ContourLine(Index) = plot(x(Index-2:Index-1), y(Index-2:Index-1), 'y', 'LineWidth', 2);
    end
    [Tempx, Tempy, button] = ginput(1);
    if (isempty(button))
        Flag = 0;
    else
        if (button == 3)
            Flag = 0;
        else
            x(Index) = Tempx;
            y(Index) = Tempy;
        end
    end
    Index = Index + 1;
end
ContourLine(Index+1) = plot([x(end) x(1)], [y(end) y(1)], 'y', 'LineWidth', 2);

% Now check if any of the limits have gone out of the plot axis
TempAxis = axis;
x(find(x < TempAxis(1))) = TempAxis(1);
x(find(x > TempAxis(2))) = TempAxis(2);

y(find(y < TempAxis(3))) = TempAxis(3);
y(find(y > TempAxis(4))) = TempAxis(4);

% First find out what syllables are currently being plotted
SyllsToPlot = get(handles.SyllableListBox, 'Value');
Indices = [];

if (SyllsToPlot(1) == 1)
    Indices = (1:1:length(handles.DataStruct.SyllIndexLabels));
    Indices = Indices(:);
else
    for i = 1:length(SyllsToPlot),
        TempIndices = find(handles.DataStruct.SyllIndexLabels == handles.ASSLAS.UniqueSylls(SyllsToPlot(i) - 1));
        Indices = [Indices; TempIndices(:)];
    end
end

% Now find points inside the polygon if there are more than 1 point in the
% polygon boundaries

if (length(x) > 1)
    Sylls = inpolygon(handles.DataStruct.FeatValues(Indices, handles.ASSLAS.XVal), handles.DataStruct.FeatValues(Indices, handles.ASSLAS.YVal), x, y);
else
    if (length(x) == 1)
        x = (x - mean(handles.DataStruct.FeatValues(Indices, handles.ASSLAS.XVal)))/std(handles.DataStruct.FeatValues(Indices, handles.ASSLAS.XVal));
        y = (y - mean(handles.DataStruct.FeatValues(Indices, handles.ASSLAS.YVal)))/std(handles.DataStruct.FeatValues(Indices, handles.ASSLAS.YVal));
        Sylls = knnsearch(zscore(handles.DataStruct.FeatValues(Indices,[handles.ASSLAS.XVal handles.ASSLAS.YVal])), [x y]);
    end
end

SyllsPlot = plot(handles.DataStruct.FeatValues(Indices(Sylls), handles.ASSLAS.XVal), handles.DataStruct.FeatValues(Indices(Sylls), handles.ASSLAS.YVal), 'yo', 'LineWidth', 2);
uiwait(gcf, 2);
   
Sylls = Indices(Sylls);
if (~isempty(Sylls))
    UniqueFiles_with_SyllsToDelete = unique(handles.DataStruct.SyllIndices(Sylls,1));
    for i = (UniqueFiles_with_SyllsToDelete(:))',
        DeleteSyllNums = handles.DataStruct.SyllIndices(intersect(Sylls, find(handles.DataStruct.SyllIndices(:,1) == i)),2);
        DeleteSyllNums = DeleteSyllNums(:)';
        
        % First get rid of onsets, offsets and labels
        handles.DataStruct.SyllOnsets{i}(DeleteSyllNums) = [];
        handles.DataStruct.SyllOffsets{i}(DeleteSyllNums) = [];
        handles.DataStruct.SyllLabels{i}(DeleteSyllNums) = [];
        
        % Now get rid of feature values corresponding to the files
        for j = 1:length(handles.DataStruct.ToBeUsedFeatures),
            eval(['handles.DataStruct.', handles.DataStruct.ToBeUsedFeatures{j}, '{', num2str(i), '}([', num2str(DeleteSyllNums), ']) = [];']);
        end
       
        % Now get rid of raw feature values
        RawFeatFields = fields(handles.DataStruct.Raw);
        for j = 1:length(RawFeatFields),
            eval(['handles.DataStruct.Raw.', RawFeatFields{j}, '{', num2str(i), '}([', num2str(DeleteSyllNums), ']) = [];']);
        end
    end
    % Now get rid of syll index labels, featvalues, rawfeatvalues, syll
    % indices
    handles.DataStruct.SyllIndexLabels(Sylls) = [];
    handles.DataStruct.SyllIndices(Sylls,:) = [];
    handles.DataStruct.FeatValues(Sylls,:) = [];
    handles.DataStruct.RawFeatValues(Sylls,:) = [];
end

for i = 1:length(ContourLine),
    if (ContourLine(i) ~= 0)
        delete(ContourLine(i));
    end
end
delete(SyllsPlot);

[handles] = RePlotSyllFeatures(handles);

guidata(hObject, handles);
disp('Finished deleting select syllables');


% ========== Common function for committing changes to labels, onsets and offsets of every file ==================
function [handles] = ReAssignSyllDetails(handles)

for i = 1:length(handles.DataStruct.FileName),
    Indices = find(handles.DataStruct.SyllIndices(:,1) == i);
    handles.DataStruct.SyllLabels{i} = handles.DataStruct.SyllIndexLabels(Indices)';
end

disp('Finished reassigning syllable onset, offset, label information');

% ========== Common function for replotting the two axis ==================
function [handles] = RePlotSyllFeatures(handles)

handles.ASSLAS.Colors = 'rgbmc';
handles.ASSLAS.Symbols = 'o+sdp<';

handles.ASSLAS.FeatNames = cellstr(get(handles.XListBox, 'String'));
handles.ASSLAS.XVal = get(handles.XListBox, 'Value');
handles.ASSLAS.YVal = get(handles.YListBox, 'Value');

ASSLASPlotData(handles, 0, [0.5 0.5 0.5], '.', 3, handles.ASSLFeaturePlotAxis);

handles.ASSLAS.UniqueSylls = unique(handles.DataStruct.SyllIndexLabels);
handles.ASSLAS.UniqueSyllColors = round(mod(0:1:(length(handles.ASSLAS.UniqueSylls)-1), length(handles.ASSLAS.Colors))) + 1;
handles.ASSLAS.UniqueSyllSymbols = ceil((1:1:length(handles.ASSLAS.UniqueSylls))/length(handles.ASSLAS.Colors));

cla(handles.ASSLASLegendAxis);
for i = 1:length(handles.ASSLAS.UniqueSylls),
    axes(handles.ASSLASLegendAxis);
    text(1, (length(handles.ASSLAS.UniqueSylls) - i + 1), [handles.ASSLAS.UniqueSylls(i), ' - ', handles.ASSLAS.Symbols(handles.ASSLAS.UniqueSyllSymbols(i)), ' - ', num2str(length(find(handles.DataStruct.SyllIndexLabels == handles.ASSLAS.UniqueSylls(i))))], 'Color', handles.ASSLAS.Colors(handles.ASSLAS.UniqueSyllColors(i)), 'FontSize', 16, 'FontWeight', 'bold');
    hold on;
end
axis([0.9 1.4 0 length(handles.ASSLAS.UniqueSylls)+1]);

set(handles.SyllableListBox, 'String', [{'All'}; handles.ASSLAS.UniqueSylls]);
set(handles.SyllableListBox, 'Max', length(handles.ASSLAS.UniqueSylls) + 1);

set(handles.CurrSyllListBox, 'String', handles.ASSLAS.UniqueSylls);

set(handles.PrevNextSyllListBox, 'String', handles.ASSLAS.UniqueSylls);
set(handles.PrevNextSyllListBox, 'Max', length(handles.ASSLAS.UniqueSylls));

CurrSyll = get(handles.CurrSyllListBox, 'Value');

PrevNextSyll = get(handles.PrevNextSyllListBox, 'Value');
PrevNext = get(handles.PrevNextSyllMenu, 'Value');

for i = 1:length(PrevNextSyll),
    if (PrevNext == 1)
        Indices = strfind(handles.DataStruct.SyllIndexLabels', [handles.ASSLAS.UniqueSylls(PrevNextSyll(i)), handles.ASSLAS.UniqueSylls(CurrSyll)]);
    else
        Indices = strfind(handles.DataStruct.SyllIndexLabels', [handles.ASSLAS.UniqueSylls(CurrSyll), handles.ASSLAS.UniqueSylls(PrevNextSyll(i))]);
    end

    if (i == 1)
        ClearAxis = 1;
    else
        ClearAxis = 0;
    end
    ASSLASPlotData(handles, 1, handles.ASSLAS.Colors(handles.ASSLAS.UniqueSyllColors(PrevNextSyll(i))), handles.ASSLAS.Symbols(handles.ASSLAS.UniqueSyllSymbols(PrevNext(i))), 4, handles.ASSLNextSyllAxis, ClearAxis, Indices);
end


