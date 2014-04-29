function dimord = getdimord(data, field, varargin)

% GETDIMORD
%
% Use as
%   dimord = getdimord(data, field)
%
% See also GETDIMSIZ


if ~isfield(data, field)
  error('field "%s" not present in data', field);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ATTEMPT 1: the specific dimord is simply present
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isfield(data, [field 'dimord'])
  dimord = data.([field 'dimord']);
  return
end

% if not present, we need some additional information about the data strucure

% nan means that the value is not known and might remain unknown
% inf means that the value is not known and but should be known
ntime     = inf;
nfreq     = inf;
nchan     = inf;
nchancmb  = inf;
nrpt      = nan;
nrpttap   = nan;
npos      = inf;
nori      = nan; % this will be 3 in many cases
ntopochan = inf;
nspike    = inf; % this is only for the first spike channel

% use an anonymous function
assign = @(var, val) assignin('caller', var, val);
% it is possible to pass additional ATTEMPTs such as nrpt, nrpttap, etc
for i=1:2:length(varargin)
  assign(varargin{i}, varargin{i+1});
end

% try to determine the size of each possible dimension in the data
if isfield(data, 'label')
  nchan = length(data.label);
end

if isfield(data, 'labelcmb')
  nchancmb = size(data.labelcmb, 1);
end

if isfield(data, 'time')
  if iscell(data.time) && ~isempty(data.time)
    ntime = length(data.time{1}); % raw data: only for the first trial
  else
    ntime = length(data.time);
  end
end

if isfield(data, 'freq')
  nfreq = length(data.freq);
end

if isfield(data, 'trial') && ft_datatype(data, 'raw')
  nrpt = length(data.trial);
end

if isfield(data, 'trialtime') && ft_datatype(data, 'spike')
  nrpt = size(data.trialtime,1);
end

if isfield(data, 'cumtapcnt')
  nrpt = size(data.cumtapcnt,1);
  if numel(data.cumtapcnt)==length(data.cumtapcnt)
    % it is a vector, hence it only represents repetitions
    nrpttap = sum(data.cumtapcnt);
  else
    % it is a matrix, hence it is repetitions by frequencies
    % this happens after  mtmconvol with keeptrials
    nrpttap = sum(data.cumtapcnt,2);
    if any(nrpttap~=nrpttap(1))
      warning('unexpected variation of the number of tapers over trials')
      nrpttap = nan;
    else
      nrpttap = nrpttap(1);
    end
  end
end

if isfield(data, 'pos')
  npos = size(data.pos,1);
end

if isfield(data, 'csdlabel')
  % this is used in PCC beamformers
  nori = length(data.csdlabel);
elseif isfinite(npos)
  % assume that there are three dipole orientations per source
  nori = 3;
end

if isfield(data, 'topolabel')
  % this is used in ICA and PCA decompositions
  ntopochan = length(data.topolabel);
end

if isfield(data, 'timestamp') && iscell(data.timestamp)
  nspike = length(data.timestamp{1}); % spike data: only for the first channel
end

% determine the size of the actual data
datsiz = getdimsiz(data, field);

tok = {'rpt' 'rpttap' 'chan' 'chancmb' 'freq' 'time' 'pos' 'ori' 'topochan'};
siz = [nrpt nrpttap nchan nchancmb nfreq ntime npos nori ntopochan];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ATTEMPT 2: a general dimord is present and might apply
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isfield(data, 'dimord')
  dimtok = cell(size(datsiz));
  
  for i=1:length(datsiz)
    sel = find(siz==datsiz(i));
    if length(sel)==1
      dimtok{i} = tok{sel};
    else
      dimtok{i} = [];
    end
  end
  if all(~cellfun(@isempty, dimtok))
    if iscell(data.(field))
      dimtok{1} = ['{' dimtok{1} '}'];
    end
    dimord = sprintf('%s_', dimtok{:});
    dimord = dimord(1:end-1);
    return
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ATTEMPT 3: look at the size of some common fields that are known
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch field
  case {'avg' 'var' 'dof'}
    if isequalwithoutnans(datsiz, [nrpt nchan ntime])
      dimord = 'rpt_chan_time';
    elseif isequalwithoutnans(datsiz, [nchan ntime])
      dimord = 'chan_time';
    end
    
  case {'powspctrm' 'fourierspctrm'}
    if isequalwithoutnans(datsiz, [nrpt nchan nfreq ntime])
      dimord = 'rpt_chan_freq_time';
    elseif isequalwithoutnans(datsiz, [nrpt nchan nfreq])
      dimord = 'rpt_chan_freq';
    elseif isequalwithoutnans(datsiz, [nchan nfreq ntime])
      dimord = 'chan_freq_time';
    elseif isequalwithoutnans(datsiz, [nchan nfreq])
      dimord = 'chan_freq';
    end
    
  case {'crsspctrm' 'cohspctrm'}
    if isequalwithoutnans(datsiz, [nrpt nchancmb nfreq ntime])
      dimord = 'rpt_chancmb_freq_time';
    elseif isequalwithoutnans(datsiz, [nrpt nchancmb nfreq])
      dimord = 'rpt_chancmb_freq';
    elseif isequalwithoutnans(datsiz, [nchancmb nfreq ntime])
      dimord = 'chancmb_freq_time';
    elseif isequalwithoutnans(datsiz, [nchancmb nfreq])
      dimord = 'chancmb_freq';
    elseif isequalwithoutnans(datsiz, [nrpt nchan nchan nfreq ntime])
      dimord = 'rpt_chan_chan_freq_time';
    elseif isequalwithoutnans(datsiz, [nrpt nchan nchan nfreq])
      dimord = 'rpt_chan_chan_freq';
    elseif isequalwithoutnans(datsiz, [nchan nchan nfreq ntime])
      dimord = 'chan_chan_freq_time';
    elseif isequalwithoutnans(datsiz, [nchan nchan nfreq])
      dimord = 'chan_chan_freq';
    end
    
  case {'cov' 'coh' 'csd' 'noisecov' 'noisecsd'}
    % these occur in timelock and in source structures
    if isequalwithoutnans(datsiz, [nrpt nchan nchan])
      dimord = 'rpt_chan_chan';
    elseif isequalwithoutnans(datsiz, [nchan nchan])
      dimord = 'chan_chan';
    elseif isequalwithoutnans(datsiz, [npos nori nori])
      if iscell(data.(field))
        dimord = '{pos}_ori_ori';
      else
        dimord = 'pos_ori_ori';
      end
    elseif isequalwithoutnans(datsiz, [npos nrpt nori nori])
      if iscell(data.(field))
        dimord = '{pos}_rpt_ori_ori';
      else
        dimord = 'pos_rpt_ori_ori';
      end
    end
    
  case {'pow'}
    if isequalwithoutnans(datsiz, [npos ntime])
      if iscell(data.(field))
        dimord = '{pos}_time';
      else
        dimord = 'pos_time';
      end
    elseif isequalwithoutnans(datsiz, [npos nrpt])
      if iscell(data.(field))
        dimord = '{pos}_rpt';
      else
        dimord = 'pos_rpt';
      end
    end
    
  case {'mom'}
    if isequalwithoutnans(datsiz, [npos nori ntime])
      if iscell(data.(field))
        dimord = '{pos}_ori_time';
      else
        dimord = 'pos_ori_time';
      end
    elseif isequalwithoutnans(datsiz, [npos nori nrpt])
      if iscell(data.(field))
        dimord = '{pos}_ori_rpt';
      else
        dimord = 'pos_ori_rpt';
      end
    elseif isequalwithoutnans(datsiz, [npos ntime])
      if iscell(data.(field))
        dimord = '{pos}_time';
      else
        dimord = 'pos_time';
      end
    end
    
  case {'trial'}
    if ~iscell(data.(field)) && isequalwithoutnans(datsiz, [nrpt nchan ntime])
      dimord = 'rpt_chan_time';
    elseif isequalwithoutnans(datsiz, [nrpt nchan ntime])
      dimord = '{rpt}_chan_time';
    elseif isequalwithoutnans(datsiz, [nchan nspike]) || isequalwithoutnans(datsiz, [nchan 1 nspike])
      dimord = '{chan}_spike';
    end
    
  case {'sampleinfo' 'trialinfo' 'trialtime'}
    if isequalwithoutnans(datsiz, [nrpt nan])
      dimord = 'rpt_unknown';
    end
    
  case {'cumtapcnt' 'cumsumcnt'}
    if isequalwithoutnans(datsiz, [nrpt nan])
      dimord = 'rpt_unknown';
    end
    
  case {'topo'}
    if isequalwithoutnans(datsiz, [ntopochan nchan])
      dimord = 'topochan_chan';
    end
    
  case {'unmixing'}
    if isequalwithoutnans(datsiz, [nchan ntopochan])
      dimord = 'chan_topochan';
    end
    
  case {'inside'}
    if isequalwithoutnans(datsiz, [npos])
      dimord = 'pos';
    end
    
  case {'timestamp' 'time'}
    if ft_datatype(data, 'spike') && iscell(data.(field)) && datsiz(1)==nchan
      dimord = '{chan}_spike';
    elseif ft_datatype(data, 'raw') && iscell(data.(field)) && datsiz(1)==nrpt
      dimord = '{rpt}_time';
    elseif isvector(data.(field)) && isequal(datsiz, [1 ntime])
      dimord = 'time';
    end

  case {'freq'}
    if isvector(data.(field)) && isequal(datsiz, [1 nfreq])
      dimord = 'freq';
    end

end % switch field


if ~exist('dimord', 'var')
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % ATTEMPT 4: compare the size with the known size of each dimension
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  sel = ~isnan(siz) & ~isinf(siz);
  % nan means that the value is not known and might remain unknown
  % inf means that the value is not known and but should be known
  if length(unique(siz(sel)))==length(siz(sel))
    % this should only be done if there is no chance of confusing dimensions
    dimtok = cell(size(datsiz));
    dimtok(datsiz==npos)      = {'pos'};
    dimtok(datsiz==nori)      = {'ori'};
    dimtok(datsiz==nrpttap)   = {'rpttap'};
    dimtok(datsiz==nrpt)      = {'rpt'};
    dimtok(datsiz==nchancmb)  = {'chancmb'};
    dimtok(datsiz==nchan)     = {'chan'};
    dimtok(datsiz==nfreq)     = {'freq'};
    dimtok(datsiz==ntime)     = {'time'};
    
    if isempty(dimtok{end}) && datsiz(end)==1
      % remove the unknown trailing singleton dimension
      dimtok = dimtok(1:end-1);
    end
    
    if all(~cellfun(@isempty, dimtok))
      if iscell(data.(field))
        dimtok{1} = ['{' dimtok{1} '}'];
      end
      dimord = sprintf('%s_', dimtok{:});
      dimord = dimord(1:end-1);
      return
    end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ATTEMPT 5: return "unknown_unknown"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('dimord', 'var')
  % this should not happen
  % if it does, it might help in diagnosis to have a very informative warning message
  warning('could not determine dimord of "%s" in the following data', field)
  disp(data);
  
  dimtok = repmat({'unknown'}, size(datsiz));
  if all(~cellfun(@isempty, dimtok))
    if iscell(data.(field))
      dimtok{1} = ['{' dimtok{1} '}'];
    end
    dimord = sprintf('%s_', dimtok{:});
    dimord = dimord(1:end-1);
  end
end

end % function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ok = isequalwithoutnans(a, b)
% this is *only* used to compare matrix sizes, so we can ignore any
% singleton last dimension
numdiff = numel(b)-numel(a);

if numdiff > 0
  % assume singleton dimensions missing in a
  a = [a(:); ones(numdiff, 1)];
  b = b(:);
elseif numdiff < 0
  % assume singleton dimensions missing in b
  b = [b(:); ones(abs(numdiff), 1)];
  a = a(:);
end

c = ~isnan(a(:)) & ~isnan(b(:));
ok = isequal(a(c), b(c));

end % function isequalwithoutnans

