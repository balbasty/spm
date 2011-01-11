function [data] = fixdimord(data, keepsourcedimord);

% FIXDIMORD ensures consistency between the dimord string and the axes
% that describe the data dimensions. The main purpose of this function
% is to ensure backward compatibility of all functions with data that has
% been processed by older FieldTrip versions
%
% Use as
%   [data] = fixdimord(data)
% This will modify the data.dimord field to ensure consistency.
% The name of the axis is the same as the name of the dimord, i.e. if
% dimord='freq_time', then data.freq and data.time should be present.
%
% The default dimensions in the data are described by
%  'time'
%  'freq'
%  'chan'
%  'refchan'
%  'rpt'
%  'subj'
%  'chancmb'
%  'rpttap'

% Copyright (C) 2009, Robert Oostenveld, Jan-Mathijs Schoffelen
%
% This file is part of FieldTrip, see http://www.ru.nl/neuroimaging/fieldtrip
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id: fixdimord.m 2528 2011-01-05 14:12:08Z eelspa $

if nargin<2, keepsourcedimord = 0; end

if strcmp('volume', ft_datatype(data)) || strcmp('source', ft_datatype(data));
  if isfield(data, 'dimord') && ~keepsourcedimord
    % data should not have a dimord (is not implemented yet, but some
    % functions add a dimord to these data which leads to unexpected behavior)
    warning('unexpected dimord "%s", dimord is removed from data', data.dimord);
    data = rmfield(data, 'dimord');
    return
  else
    %is okay
    return
  end
end

if ~isfield(data, 'dimord')
  if ~isfield(data, 'trial') || ~iscell(data.trial) || ...
     ~isfield(data, 'time')  || ~iscell(data.time)  || ...
     ~isfield(data, 'label') || ~iscell(data.label)
    error('The data does not contain a dimord, but it also does not resemble raw data');
  elseif isfield(data, 'topo')
    % the data resembles a component decomposition
    data.dimord = 'chan_comp';
  else
    % the data does not contain a dimord, but it resembles raw data -> that's ok
    return
  end
end

dimtok = tokenize(data.dimord, '_');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:length(dimtok)
  switch dimtok{i}
    case {'tim' 'time' 'toi' 'latency'}
      dimtok{i} = 'time';

    case {'frq' 'freq' 'foi' 'frequency'}
      dimtok{i} = 'freq';

    case {'sgn' 'label' 'chan'}
      dimtok{i} = 'chan';

    case {'rpt' 'trial'}
      dimtok{i} = 'rpt';

    case {'subj' 'subject'}
      dimtok{i} = 'subj';

    case {'comp'}
      % don't change, it is ok

    case {'sgncmb' 'labelcmb' 'chancmb'}
      dimtok{i} = 'chan';

    case {'rpttap'}
      % this is a 2-D field, coding trials and tapers along the same dimension
      % don't change, it is ok

    case {'refchan'}
      % don't change, it is ok

    case {'vox' 'repl' 'wcond'}
      % these are used in some fieldtrip functions, but are not considered standard
      warning('unexpected dimord "%s"', data.dimord);

    case {'pos'}
      % this will be the future default for simple sources

    otherwise
      error(sprintf('unexpected dimord "%s"', data.dimord));

  end % switch dimtok
end % for length dimtok

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isfield(data, 'tim'),         data.time      = data.tim         ; data = rmfield(data, 'tim')        ; end
if isfield(data, 'toi'),         data.time      = data.toi         ; data = rmfield(data, 'toi')        ; end
if isfield(data, 'latency'),     data.time      = data.latency     ; data = rmfield(data, 'latency')    ; end
if isfield(data, 'frq'),         data.freq      = data.frq         ; data = rmfield(data, 'frq')        ; end
if isfield(data, 'foi'),         data.freq      = data.foi         ; data = rmfield(data, 'foi')        ; end
if isfield(data, 'frequency'),   data.freq      = data.frequency   ; data = rmfield(data, 'frequency')  ; end
if isfield(data, 'sgn'),         data.label     = data.sgn         ; data = rmfield(data, 'sgn')        ; end
if isfield(data, 'chan'),        data.label     = data.chan        ; data = rmfield(data, 'chan')       ; end
% if isfield(data, 'trial'),         data.rpt     = data.trial         ; data = rmfield(data, 'trial')        ; end  % DO NOT CONVERT -> this is an exception
if isfield(data, 'subject'),     data.subj      = data.subject     ; data = rmfield(data, 'subject')    ; end
if isfield(data, 'sgncmb'),      data.labelcmb  = data.sgncmb      ; data = rmfield(data, 'sgncmb')     ; end
if isfield(data, 'chancmb'),     data.labelcmb  = data.chancmb     ; data = rmfield(data, 'chancmb')    ; end

% ensure that it is a column
if isfield(data, 'label')
  data.label = data.label(:);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if isfield(data, 'trial')
%   mat = data.trial;
% elseif isfield(data, 'individual')
%   mat = data.individual;
% elseif isfield(data, 'avg')
%   mat = data.avg;
% elseif isfield(data, 'crsspctrm')
%   mat = data.crsspctrm;
% elseif isfield(data, 'powspctrm')
%   mat = data.powspctrm;
% elseif isfield(data, 'fourierspctrm')
%   mat = data.fourierspctrm;
% end
%
% add the descriptive axis for each dimension
% for i=1:length(dimtok)
%   if isfield(data, dimtok{i})
%     % the dimension is already described with its own axis
%     % data = setfield(data, dimtok{i}, getfield(data, dimtok{i}));
%   else
%     % add an axis to the output data
%     data = setfield(data, dimtok{i}, 1:size(mat,i));
%   end
% end

% undo the tokenization
data.dimord = dimtok{1};
for i=2:length(dimtok)
  data.dimord = [data.dimord '_' dimtok{i}];
end

