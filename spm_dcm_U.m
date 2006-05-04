function [] = spm_dcm_U (DCM_filename,SPM_filename,session,input_nos)
% Insert new inputs into a DCM model
% FORMAT [] = spm_dcm_U (DCM_filename,SPM_filename,session,input_nos)
%
% DCM_filename      Name of DCM file
% SPM_filename      Name of SPM file (eg. 'SPM')
% session           Session number (eg. 1)
% input_nos         Inputs to include and their parametric modulations (PMs).
%                   Example for a case without PM: {1, 0, 1} includes inputs 1 and 3.
%                   Example for a case with PM:    {1,0,[0 0 1],[0 1]} includes the
%                   non-modulated first input, the second PM of the third
%                   input and the first PM of the fourth input.  Note that
%                   this cell array only has to be specified up to the last
%                   input that is replaced.
%
% This function can be used, for example, to replace subject X's inputs by subject Y's.
% The model can then be re-estimated without having to go through
% model specification again.
%
%_______________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% Will Penny & Klaas Enno Stephan
% $Id: spm_dcm_U.m 507 2006-05-04 05:44:19Z Darren $


load(DCM_filename);
load(SPM_filename);

if session>length(SPM.Sess)
    disp(sprintf('Error in spm_dcm_U: SPM file does not have %d sessions',session));
    return
end
Sess   = SPM.Sess(session);


% Check numbers of inputs match
%------------------------------------------------------------------------
% Number of selected inputs from SPM file
m_sel  = length(find(cell2mat(input_nos)));

% Number of inputs in DCM file
m      = size(DCM.c,2);

if ~(m_sel==m)
    disp(sprintf('Error in spm_dcm_U: must include %d inputs',m));
    return
end


% Replace inputs
%------------------------------------------------------------------------
% Number of inputs in SPM file
u      = length(Sess.U);

% Last relevant input
u_last = max(size(input_nos));
if u_last > u 
    disp('Error in spm_dcm_U: more inputs specified than exist in SPM.mat');
    return
end

% Loop through all specified inputs and store them in U
U.name = {};
U.u    = [];
U.dt   = DCM.U.dt;
for k = 1:u_last,
    if find(input_nos{k})
        mo = find(input_nos{k});
        if ~(all(mo <= length(Sess.U(k).P.i))) 
            disp(['Error in spm_dcm_U: more parametric modulations specified than exist for input ' Sess.U(k).name{1} 'in SPM file.']);
            return
        end
        for j=mo,
            U.u             = [U.u Sess.U(k).u(33:end,j)];
            U.name{end + 1} = Sess.U(k).name{j};
        end
    end 
end   
DCM.U = U;


% Check inputs and outputs match up (to the nearest DCM.U.dt)
%--------------------------------------------------------------------------
% Get input sampling rate from first input
U.dt          = Sess.U(1).dt;

% Use the TR from the SPM data structure
DCM.Y.dt      = SPM.xY.RT;

num_inputs    = size(DCM.U.u,1);
input_period  = DCM.U.dt*num_inputs;
output_period = DCM.v*DCM.Y.dt;
if ~(round(DCM.v*DCM.Y.dt/DCM.U.dt) == num_inputs)
    disp('Error in spm_dcm_U: input period and output period do not match');
    disp(sprintf('Number of inputs=%d, input dt=%1.2f, input period=%1.2f',num_inputs,DCM.U.dt,input_period));
    disp(sprintf('Number of outputs=%d, output dt=%1.2f, output period=%1.2f',DCM.v,DCM.Y.dt,output_period));
    return
end


% Save DCM with replaced inputs
%--------------------------------------------------------------------------
if spm_matlab_version_chk('7.1') >= 0
    save(DCM_filename, 'DCM','-V6');
else
    save(DCM_filename, 'DCM');
end;

return 
