function res = badchannels(this, varargin)
% Method for getting/setting bad channels
% FORMAT res = badchannels(this)
% _______________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% Stefan Kiebel
% $Id: badchannels.m 4432 2011-08-15 12:43:44Z christophe $

if length(varargin) == 2 && ~isempty(varargin{1})
    % make sure that the two inputs for set are the same length
    if ~(length(varargin{2}) == 1 | (length(varargin{1}) == length(varargin{2})))
        error('Use either same vector length or scalar for value');
    end
end

if numel(varargin) >= 1  && ~isempty(varargin{1})  
    if ~(all(varargin{1} >= 1) && all(varargin{1} <= nchannels(this)))
        error('Channel number out of range.');
    end
end

if numel(varargin) >= 2
    ubad = unique(varargin{2});
    if isempty(ubad) | ~all(ismember(ubad, [0 1]))
        error('Illegal bad flags (should be 0 or 1)');
    end
end

if this.montage.Mind == 0
    res = getset(this, 'channels', 'bad', varargin{:});
else 
    res = getset(this.montage.M(this.montage.Mind), 'channels', 'bad', varargin{:});
end


if isempty(varargin)
    if iscell(res)
        res = [res{:}];
    end
    
    res = find(res);
end
