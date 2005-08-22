function D = spm_eeg_average(S);
% averages each channel over trials or trial types.
% FORMAT D = spm_eeg_average(S)
%
% S		    - optional input struct
% (optional) fields of S:
% D			- filename of EEG mat-file with epoched data
%
% Output:
% D			- EEG data struct (also written to files)
%_______________________________________________________________________
%
% spm_eeg_average averages single trial data within trial type. 
%_______________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% Stefan Kiebel
% $Id: spm_eeg_average.m 213 2005-08-22 12:43:29Z stefan $

[Finter,Fgraph,CmdLine] = spm('FnUIsetup','EEG averaging setup',0);

try
	D = S.D;
catch
    D = spm_select(1, '.*\.mat$', 'Select EEG mat file');
end

P = spm_str_manip(D, 'H');

try
	D = spm_eeg_ldata(D);
catch    
	error(sprintf('Trouble reading file %s', D));
end

D.fnamedat = ['m' D.fnamedat];

fpd = fopen(fullfile(P, D.fnamedat), 'w');

spm('Pointer', 'Watch'); drawnow;


if isfield(D, 'Nfrequencies');
	D.scale.dim = [1 4];
	D.scale.values = zeros(D.Nchannels, D.events.Ntypes);
	
	for i = 1:D.events.Ntypes
		d = mean(D.data(:,:,:, find((D.events.code == D.events.types(i)) & ~D.events.reject)), 4);
		
		D.scale.values(:, i) = max(max(abs(d), [], 3), [], 2)./32767;
		d = int16(d./repmat(D.scale.values(:, i), [1, D.Nfrequencies, D.Nsamples]));
		fwrite(fpd, d, 'int16');
	end
	
else
	
	if isfield(D, 'weights');	
		d = zeros(D.Nchannels, D.Nsamples);
		D.scale.dim = [1 3];
		D.scale.values = zeros(D.Nchannels, D.events.Ntypes);
		for i = 1:D.events.Ntypes
			
			for j = 1:D.Nchannels
				tempwf=[];
				ti=0;
				ts=0;
				while ts==0
					ti=ti+1;
					ts=(j==D.channels.thresholded{ti});
					
				end
				
				if isempty(ts)
					data=squeeze(D.data(j,:,find(D.events.code==D.events.types(i))))';
					ndata=reshape(data',size(data,1)*size(data,2),1);
					Xs=sparse(repmat(speye(size(data,2)),[size(data,1),1]));
					Wis=speye(length(ndata));
					for nl=(find(D.events.code==D.events.types(i)));
						
						tempwf=[tempwf,D.weights(j,(nl-1)*D.Nsamples+1:nl*D.Nsamples)];
					end
					Wis=spdiags(tempwf',0,Wis);
					
					d(j, :) =(((Xs'*Wis*Xs)^-1)*Xs'*Wis*ndata)';
				else
					d(j,:)=zeros(1,D.Nsamples);
				end
			end
			D.scale.values(:, i) = spm_eeg_write(fpd, d, 2, D.datatype);
			
		end           
	else
		
		D.scale.dim = [1 3];
        Ntypes = D.events.Ntypes;
		D.scale.values = zeros(D.Nchannels, Ntypes);
		
		spm_progress_bar('Init', Ntypes, 'Averages done'); drawnow;
		if Ntypes > 100, Ibar = floor(linspace(1, Ntypes, 100));
		else, Ibar = [1:Ntypes]; end
		
		for i = 1:Ntypes
			
            w = (D.events.code == D.events.types(i) & ~D.events.reject)';
			
			ni(i) = length(w);
			
			d = zeros(D.Nchannels, D.Nsamples);
			
			if ni(i) == 0
				warning('%s: No trials for trial type %d', D.fname, D.events.types(i)); 
            else
                
                w = w./sum(w); % vector of trial-wise weights
				for j = 1:D.Nchannels
					d(j, :) = w'*squeeze(D.data(j, :, :))';
				end
            end
			
			D.scale.values(:, i) = spm_eeg_write(fpd, d, 2, D.datatype);
			
			if ismember(i, Ibar)
				spm_progress_bar('Set', i);
				drawnow;
			end
			
		end
	end
	
	spm_progress_bar('Clear');
end
fclose(fpd);

D.Nevents = Ntypes;

D.events.code = D.events.types;
D.events.time = [];

if ~isfield(D, 'Nfrequencies');

    D.events.repl = ni;
	disp(sprintf('%s: Number of replications per contrast:', D.fname))
	s = [];
	for i = Ntypes
		s = [s sprintf('average %d: %d trials', D.events.types(i), D.events.repl(i))];
		if i < D.events.Ntypes
			s = [s sprintf(', ')];
		else
			s = [s '\n'];
		end
	end 
	disp(sprintf(s))
end

D.data = [];
D.events.reject = zeros(1, D.Nevents);
D.events.blinks = zeros(1, D.Nevents);

D.fname = ['m' D.fname];

if str2num(version('-release'))>=14
	save(fullfile(P, D.fname), '-V6', 'D');
else
	save(fullfile(P, D.fname), 'D');
end

spm('Pointer', 'Arrow');
