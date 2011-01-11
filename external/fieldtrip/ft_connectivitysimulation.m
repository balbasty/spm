function [data] = ft_connectivitysimulation(cfg)

% FT_CONNECTIVITYSIMULATION simulates time series data with a specified
% connectivity structure. 
%
% Use as
%   [data] = ft_connectivitysimulation(cfg)
% 
% where the configuration structure should contain:
%
% cfg.method      = string, can be one of the following: 
%                    'linear_mix', 'mvnrnd', 'ar' (see below)
% cfg.nsignal     = scalar, number of signals
% cfg.ntrials     = scalar, number of trials
% cfg.triallength = in seconds
% cfg.fsample     = in Hz
% 
% In addition for the specific methods the configuration may 
% also contain:
%
% Method 'linear_mix' implements a linear mixing with optional time shifts
% where the number of unobserved signals can be different from the number
% of observed signals
%
%   Required cfg options: 
%      cfg.mix    = matrix, [nsignal x number of unobserved signals] 
%                           specifying the mixing from the unobserved signals to 
%                           the observed signals, or
%                 = matrix, [nsignal x number of unobserved signals x number of
%                           samples] specifying the mixing from the
%                           unobserved signals to the observed signals which
%                           changes as a function of time within the trial
%                 = cell-arry, [1 x ntrials] with each cell a matrix as
%                              specified above, when a trial-specific mixing is
%                              required
%      cfg.delay  = matrix, [nsignal x number of unobserved signals]
%                           specifying the time shift (in samples) between the
%                           unobserved signals and the observed signals
%   Optional cfg options:
%      cfg.bpfilter  = 'yes' (or 'no')
%      cfg.bpfreq    = [bplow bphigh] (default: [15 25])
%      cfg.demean    = 'yes' (or 'no')
%      cfg.baselinewindow = [begin end] in seconds, the default is the complete trial 
%      cfg.absnoise  = scalar (default: 1), specifying the standard
%                             deviation of white noise superimposed on top
%                             of the simulated signals
%
% Method 'mvnrnd' implements a linear mixing with optional timeshifts in
% where the number of unobserved signals is equal to the number of observed
% signals. This method used the matlab function mvnrnd. The implementation
% is a bit ad-hoc and experimental, so users are discouraged to apply it.
% The time shift occurs only after the linear mixing, so the effect of the 
% parameters on the simulation is not really clear. This method will be
% disabled in the future.
%
%   Required cfg options:
%      cfg.covmat      = covariance matrix between the signals
%      cfg.delay       = delay vector between the signals in samples
%   Optional cfg options:
%      cfg.bpfilter  = 'yes' (or 'no')
%      cfg.bpfreq    = [bplow bphigh] (default: [15 25])
%      cfg.demean    = 'yes' (or 'no')
%      cfg.baselinewindow = [begin end] in seconds, the default is the complete trial 
%      cfg.absnoise  = scalar (default: 1), specifying the standard
%                             deviation of white noise superimposed on top
%                             of the simulated signals
%
% Method 'ar' implements an multivariate autoregressive model to generate
% the data.
% 
%   Required cfg options:
%      cfg.params   = matrix, [nsignal x nsignal x number of lags] specifying the
%                             autoregressive coefficient parameters 
%      cfg.noisecov = matrix, [nsignal x nsignal] specifying the covariance
%                             matrix of the innovation process
% 
% The output is a raw data structure.
%
% See also FT_FREQSIMULATION, FT_DIPOLESIMULATION, FT_SPIKESIMULATION,
% FT_CONNECTIVITYANALYSIS

% Copyright (C) 2009, Donders Institute for Brain, Cognition and Behaviour
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
% $Id: ft_connectivitysimulation.m 2422 2010-12-15 08:44:29Z jansch $

% check input configuration for the generally applicable options
cfg = ft_checkconfig(cfg, 'required', {'nsignal' 'ntrials' 'triallength' 'fsample' 'method'});
cfg = ft_checkconfig(cfg, 'rename',   {'blc', 'demean'});

% method specific defaults
switch cfg.method
case {'linear_mix'}
  %method specific defaults
  if ~isfield(cfg, 'bpfilter'), cfg.bpfilter = 'yes';   end
  if ~isfield(cfg, 'bpfreq'),   cfg.bpfreq   = [15 25]; end
  if ~isfield(cfg, 'demean'),   cfg.dmean    = 'yes';   end
  if ~isfield(cfg, 'absnoise'), cfg.absnoise = 1;       end
  cfg = ft_checkconfig(cfg, 'required', {'mix' 'delay'});
case {'mvnrnd'}
  if ~isfield(cfg, 'bpfilter'), cfg.bpfilter = 'yes';   end
  if ~isfield(cfg, 'bpfreq'),   cfg.bpfreq   = [15 25]; end
  if ~isfield(cfg, 'demean'),   cfg.demean   = 'yes';   end
  if ~isfield(cfg, 'absnoise'), cfg.absnoise = 1;       end
  cfg = ft_checkconfig(cfg, 'required', {'covmat' 'delay'}); 
case {'ar'}
  cfg = ft_checkconfig(cfg, 'required', {'params' 'noisecov'});
otherwise
end

trial = cell(1, cfg.ntrials);
time  = cell(1, cfg.ntrials);
nsmp  = round(cfg.triallength*cfg.fsample);
tim   = (0:nsmp-1)./cfg.fsample;

% create the labels
for k = 1:cfg.nsignal
  label{k,1} = ['signal',num2str(k,'%03d')];
end

switch cfg.method
case {'linear_mix'}

  fltpad = 50; %hard coded to avoid filtering artifacts
  delay  = cfg.delay;
  delay  = delay - min(delay(:)); %make explicitly >= 0
  maxdelay = max(delay(:));

  if iscell(cfg.mix),
    %each trial has different mix
    mix = cfg.mix;            
  else
    %make cell-array out of mix
    tmpmix = cfg.mix;
    mix    = cell(1,cfg.ntrials);
    for tr = 1:cfg.ntrials
      mix{1,tr} = tmpmix;
    end
  end
  
  nmixsignal = size(mix{1}, 2); %number of "mixing signals"
  nsignal    = size(mix{1}, 1);

  if numel(size(mix{1}))==2,
    %mix is static, no function of time
    for tr = 1:cfg.ntrials
      mix{tr} = mix{tr}(:,:,ones(1,nsmp+maxdelay));
    end
  elseif numel(size(mix{1}))==3 && size(mix{1},3)==nsmp,
    %mix changes with time
    for tr = 1:cfg.ntrials
      mix{tr} = cat(3,mix{tr},mix{tr}(:,:,nsmp*ones(1,maxdelay))); 
    end
    %FIXME think about this
    %due to the delay the mix cannot be defined instantaneously with respect to all signals
  end
    
  for tr = 1:cfg.ntrials
    mixsignal = randn(nmixsignal,  nsmp + 2*fltpad + maxdelay);
    mixsignal = preproc(mixsignal, label, cfg.fsample, cfg, -fltpad, fltpad, fltpad);
    tmp       = zeros(cfg.nsignal, nsmp);
    for i=1:cfg.nsignal
      for j=1:nmixsignal
        begsmp   = 1    + delay(i,j);
        endsmp   = nsmp + delay(i,j);
        tmpmix   = reshape(mix{tr}(i,j,:),[1 nsmp+maxdelay]) .* mixsignal(j,:);
        tmp(i,:) = tmp(i,:) + tmpmix(begsmp:endsmp);
      end
    end
    trial{tr} = tmp;
    
    % add some noise
    trial{tr} = ft_preproc_baselinecorrect(trial{tr} + cfg.absnoise*randn(size(trial{tr})));
    
    % define time axis for this trial
    time{tr}  = tim;
  end

case {'mvnrnd'}
  fltpad = 100; %hard coded
  
  shift = max(cfg.delay(:,1)) - cfg.delay(:,1);
  for k = 1:cfg.ntrials
    % create the multivariate time series plus some padding
    tmp = mvnrnd(zeros(1,cfg.nsignal), cfg.covmat, nsmp+2*fltpad+max(shift))';
  
    % add the delays
    newtmp = zeros(cfg.nsignal, nsmp+2*fltpad);
    for kk = 1:cfg.nsignal
      begsmp =      + shift(kk) + 1;
      endsmp = nsmp + 2*fltpad + shift(kk);
      newtmp(kk,:) = ft_preproc_baselinecorrect(tmp(kk,begsmp:endsmp));
    end
  
    % apply preproc
    newtmp = preproc(newtmp, label, cfg.fsample, cfg, -fltpad, fltpad, fltpad);
  
    trial{k} = newtmp;
    
    % add some noise
    trial{k} = ft_preproc_baselinecorrect(trial{k} + cfg.absnoise*randn(size(trial{k})));
  
    % define time axis for this trial
    time{k}  = tim;
  end
case {'ar'}
  nlag    = size(cfg.params,3);
  nsignal = cfg.nsignal;
  params  = zeros(nlag*nsignal, nsignal);
  for k = 1:nlag
    params(((k-1)*nsignal+1):k*nsignal,:) = cfg.params(:,:,k);
  end 
  for k = 1:cfg.ntrials
    tmp   = zeros(nsignal, nsmp+nlag);
    noise  = mvnrnd(zeros(nsignal,1), cfg.noisecov, nsmp+nlag)';
    state0 = zeros(nsignal*nlag, 1);
    for m = 1:nlag
      indx = ((m-1)*nsignal+1):m*nsignal;
      state0(indx) = params(indx,:)'*noise(:,m);    
    end
    tmp(:,1:nlag) = fliplr(reshape(state0, [nsignal nlag]));  
    
    for m = (nlag+1):(nsmp+nlag)
       state0    = reshape(fliplr(tmp(:,(m-nlag):(m-1))), [nlag*nsignal 1]);
       tmp(:, m) = params'*state0 + noise(:,m); 
    end
    trial{k} = tmp(:,nlag+1:end);
    time{k}  = tim;
  end  

otherwise
  error('unknown method');
end

% create the output data
data         = [];
data.trial   = trial;
data.time    = time;
data.fsample = cfg.fsample;
data.label   = label;

% add version details to the configuration
cfg.version.name = mfilename('fullpath');
cfg.version.id   = '$Id: ft_connectivitysimulation.m 2422 2010-12-15 08:44:29Z jansch $';

% add information about the Matlab version used to the configuration
cfg.version.matlab = version();

% remember the configuration details of the input data
try, cfg.previous = data.cfg; end
% remember the exact configuration details in the output 
data.cfg     = cfg;
