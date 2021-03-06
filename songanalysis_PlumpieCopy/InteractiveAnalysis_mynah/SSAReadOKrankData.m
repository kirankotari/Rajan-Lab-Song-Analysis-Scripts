function [Data, Fs] = SSAReadOKrankData(DirectoryName, RecFileDirectoryName, FileName, ChanNo)

if (ischar(ChanNo))
    ChanNo = str2double(ChanNo);
end

Data = [];
Fs = [];
PresentDirectory = pwd;

cd(DirectoryName);

if (ispc)
    [recfid, message] = fopen([RecFileDirectoryName, '\', FileName, '.rec'], 'r');
else
    [recfid, message] = fopen([RecFileDirectoryName, '/', FileName, '.rec'], 'r');
end

disp(FileName);

if ((recfid) > 0)
    while (~feof(recfid))
        tline = fgetl(recfid);
        if (strfind(tline, 'ai_freq'))
            ColonIndex = find(tline == ':');
            Fs = str2double(tline((ColonIndex + 1):end));
        end

        if (strfind(tline, 'n_ai_chan'))
            ColonIndex = find(tline == ':');
            NoOfChannels = str2double(tline((ColonIndex + 1):end));
        end

        if (strfind(tline, 'n_samples'))
            ColonIndex = find(tline == ':');
            NoOfSamples = str2double(tline((ColonIndex + 1):end));
            break;
        end
    end

    fclose(recfid);

    [datafid, message] = fopen(FileName, 'r');
   
    fseek(datafid, (ChanNo - 1) * 2, 'bof');
    [Data, num_read] = fread(datafid, inf, 'uint16', (NoOfChannels - 1) * 2);
    Data = (Data - 32768) * 10/32768;
    %Data = Data *100;
    if (num_read ~= NoOfSamples)
        disp(['No of samples does not match that of recfile: ',FileName]);
    end
    if ((datafid) > 0)
        fclose(datafid);
    end

end
   
  
cd(PresentDirectory);

