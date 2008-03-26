function S = spm_cfg_eeg_downsample
% configuration file for M/EEG downsampling
%_______________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% Stefan Kiebel
% $Id: spm_cfg_eeg_downsample.m 1253 2008-03-26 21:28:33Z stefan $

D = cfg_files;
D.tag = 'D';
D.name = 'File Name';
D.filter = 'mat';
D.num = [1 1];
D.help = {'Select the M/EEG mat file.'};

fsample_new = cfg_entry;
fsample_new.tag = 'fsample_new';
fsample_new.name = 'New sampling rate';
fsample_new.strtype = 'r';
fsample_new.num = [1 1];
fsample_new.help = {'Input the new sampling rate [Hz].'};

S = cfg_exbranch;
S.tag = 'eeg_downsample';
S.name = 'M/EEG downsampling';
S.val = {D fsample_new};
S.help = {'Downsample EEG/MEG data.'};
S.prog = @eeg_downsample;
S.vout = @vout_eeg_downsample;
S.modality = {'EEG'};


function out = eeg_downsample(job)
% construct the S struct
S.D = job.D{1};
S.fsample_new = job.fsample_new;
out.D = spm_eeg_downsample(S);

function dep = vout_eeg_downsample(job)
% Output is always in field "D", no matter how job is structured
dep = cfg_dep;
dep.sname = 'Downsample Data';
% reference field "D" from output
dep.src_output = substruct('.','D');
% this can be entered into any evaluated input
dep.tgt_spec   = cfg_findspec({{'strtype','e'}});


