function [EventCodes, segHdr, eventData] = read_sbin_events(filename)

% READ_SBIN_EVENTS reads the events information from an EGI segmented simple binary format file
%
% Use as
%   [EventCodes, segHdr, eventData] = read_sbin_events(filename)
% with
%   EventCodes      - if NEvent (from header_array) != 0, then array of 4-char event names
%   segHdr          - condition codes and time stamps for each segment
%   eventData       - if NEvent != 0 then event state for each sample, else 'none'
% and
%   filename    - the name of the data file
%_______________________________________________________________________
%
%
% Modified from EGI's readEGLY.m with permission 2008-03-31 Joseph Dien
%

fid=fopen([filename],'r');
if fid==-1
  error('wrong filename')
end

version		= fread(fid,1,'int32');

%check byteorder
[str,maxsize,cEndian]=computer;
if version < 7
  if cEndian == 'B'
    endian = 'ieee-be';
  elseif cEndian == 'L'
    endian = 'ieee-le';
  end;
elseif (version > 6) && ~bitand(version,6)
  if cEndian == 'B'
    endian = 'ieee-le';
  elseif cEndian == 'L'
    endian = 'ieee-be';
  end;
  version = swapbytes(uint32(version));
else
    error('ERROR:  This is not a simple binary file.  Note that NetStation does not successfully directly convert EGIS files to simple binary format.\n');
end;

precision = bitand(version,6);
if precision == 0
    error('File precision is not defined.');
end;

%		read header...
	year		= fread(fid,1,'int16',endian);
	month		= fread(fid,1,'int16',endian);
	day			= fread(fid,1,'int16',endian);
	hour		= fread(fid,1,'int16',endian);
	minute		= fread(fid,1,'int16',endian);
	second		= fread(fid,1,'int16',endian);
	millisecond = fread(fid,1,'int32',endian);
	Samp_Rate	= fread(fid,1,'int16',endian);
	NChan		= fread(fid,1,'int16',endian);
	Gain 		= fread(fid,1,'int16',endian);
	Bits 		= fread(fid,1,'int16',endian);
	Range 		= fread(fid,1,'int16',endian);
	NumCategors	= fread(fid,1,'int16',endian);
	for j = 1:NumCategors
 		CatLengths(j)	= fread(fid,1,'int8',endian);
		for i = 1:CatLengths(j)
			CateNames(j,i)	= char(fread(fid,1,'char',endian));
 		end
	end
	NSegments	= fread(fid,1,'int16',endian);
 	NSamples	= fread(fid,1,'int32',endian);			% samples per segment
	NEvent		= fread(fid,1,'int16',endian);			% num events per segment
    EventCodes = [];
	for j = 1:NEvent
 		EventCodes(j,1:4)	= char(fread(fid,[1,4],'char',endian));
	end

    if readNumSegments == 0
        readNumSegments = NSegments;            % If first and last segments not specified, read all of them.
    end;
    
	header_array 	= double([version year month day hour minute second millisecond Samp_Rate NChan Gain Bits Range NumCategors, NSegments, NSamples, NEvent]);

	for j = 1:firstSegment-1
        switch precision
            case 2
		        throwAway	= fread(NChan+NEvent, NSamples, 'int16',endian);
            case 4
		        throwAway	= fread(NChan+NEvent, NSamples, 'single',endian);
            case 6
		        throwAway	= fread(NChan+NEvent, NSamples, 'double',endian);
        end
	end

	eventData	= zeros(NEvent,readNumSegments*NSamples);
    segHdr      = zeros(readNumSegments,2);
	
    if (NEvent ~= 0)
        for j = 1:readNumSegments
            [segHdr(j,1), count]	= fread(fid, 1,'int16',endian);    %cell
            [segHdr(j,2), count]	= fread(fid, 1,'int32',endian);    %time stamp
            switch precision
                case 2
                    [temp,count]	= fread(fid,[NChan+NEvent, NSamples],'int16',endian);
                case 4
                    [temp,count]	= fread(fid,[NChan+NEvent, NSamples],'single',endian);
                case 6
                    [temp,count]	= fread(fid,[NChan+NEvent, NSamples],'double',endian);
            end
            eventData(:,((j-1)*NSamples+1):j*NSamples)	= temp( (NChan+1):(NChan+NEvent), 1:NSamples);
        end
    end
fclose(fid);
