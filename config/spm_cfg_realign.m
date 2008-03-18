function realign = spm_cfg_realign
% SPM Configuration file
% automatically generated by the MATLABBATCH utility function GENCODE
%_______________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% $Id: spm_cfg_realign.m 1223 2008-03-18 11:45:10Z volkmar $

% ---------------------------------------------------------------------
% data Session
% ---------------------------------------------------------------------
data         = cfg_files;
data.tag     = 'data';
data.name    = 'Session';
data.help    = {'Select scans for this session. In the coregistration step, the sessions are first realigned to each other, by aligning the first scan from each session to the first scan of the first session.  Then the images within each session are aligned to the first image of the session. The parameter estimation is performed this way because it is assumed (rightly or not) that there may be systematic differences in the images between sessions.'};
data.filter = 'image';
data.ufilter = '.*';
data.num     = [1 Inf];
% ---------------------------------------------------------------------
% generic Data
% ---------------------------------------------------------------------
generic         = cfg_repeat;
generic.tag     = 'generic';
generic.name    = 'Data';
generic.help    = {'Add new sessions for this subject. In the coregistration step, the sessions are first realigned to each other, by aligning the first scan from each session to the first scan of the first session.  Then the images within each session are aligned to the first image of the session. The parameter estimation is performed this way because it is assumed (rightly or not) that there may be systematic differences in the images between sessions.'};
generic.values  = { data};
generic.num     = [1 Inf];
% ---------------------------------------------------------------------
% quality Quality
% ---------------------------------------------------------------------
quality         = cfg_entry;
quality.tag     = 'quality';
quality.name    = 'Quality';
quality.val{1} = double(0.900000000000000022);
quality.help    = {'Quality versus speed trade-off.  Highest quality (1) gives most precise results, whereas lower qualities gives faster realignment. The idea is that some voxels contribute little to the estimation of the realignment parameters. This parameter is involved in selecting the number of voxels that are used.'};
quality.strtype = 'r';
quality.num     = [1 1];
quality.extras = double([0 1]);
% ---------------------------------------------------------------------
% sep Separation
% ---------------------------------------------------------------------
sep         = cfg_entry;
sep.tag     = 'sep';
sep.name    = 'Separation';
sep.val{1} = double(4);
sep.help    = {'The separation (in mm) between the points sampled in the reference image.  Smaller sampling distances gives more accurate results, but will be slower.'};
sep.strtype = 'e';
sep.num     = [1 1];
% ---------------------------------------------------------------------
% fwhm Smoothing (FWHM)
% ---------------------------------------------------------------------
fwhm         = cfg_entry;
fwhm.tag     = 'fwhm';
fwhm.name    = 'Smoothing (FWHM)';
fwhm.val{1} = double(5);
fwhm.help    = {
                'The FWHM of the Gaussian smoothing kernel (mm) applied to the images before estimating the realignment parameters.'
                ''
                '    * PET images typically use a 7 mm kernel.'
                ''
                '    * MRI images typically use a 5 mm kernel.'
}';
fwhm.strtype = 'e';
fwhm.num     = [1 1];
% ---------------------------------------------------------------------
% rtm Num Passes
% ---------------------------------------------------------------------
rtm         = cfg_menu;
rtm.tag     = 'rtm';
rtm.name    = 'Num Passes';
rtm.val{1} = double(1);
rtm.help    = {
               'Register to first: Images are registered to the first image in the series. Register to mean:   A two pass procedure is used in order to register the images to the mean of the images after the first realignment.'
               ''
               'PET images are typically registered to the mean. This is because PET data are more noisy than fMRI and there are fewer of them, so time is less of an issue.'
               ''
               'MRI images are typically registered to the first image.  The more accurate way would be to use a two pass procedure, but this probably wouldn''t improve the results so much and would take twice as long to run.'
}';
rtm.labels = {
              'Register to first'
              'Register to mean'
}';
rtm.values{1} = double(0);
rtm.values{2} = double(1);
% ---------------------------------------------------------------------
% interp Interpolation
% ---------------------------------------------------------------------
interp         = cfg_menu;
interp.tag     = 'interp';
interp.name    = 'Interpolation';
interp.val{1} = double(2);
interp.help    = {'The method by which the images are sampled when estimating the optimum transformation. Higher degree interpolation methods provide the better interpolation, but they are slower because they use more neighbouring voxels /* \cite{thevenaz00a,unser93a,unser93b}*/. '};
interp.labels = {
                 'Trilinear (1st Degree)'
                 '2nd Degree B-Spline'
                 '3rd Degree B-Spline '
                 '4th Degree B-Spline'
                 '5th Degree B-Spline'
                 '6th Degree B-Spline'
                 '7th Degree B-Spline'
}';
interp.values{1} = double(1);
interp.values{2} = double(2);
interp.values{3} = double(3);
interp.values{4} = double(4);
interp.values{5} = double(5);
interp.values{6} = double(6);
interp.values{7} = double(7);
% ---------------------------------------------------------------------
% wrap Wrapping
% ---------------------------------------------------------------------
wrap         = cfg_menu;
wrap.tag     = 'wrap';
wrap.name    = 'Wrapping';
wrap.val{1} = double([0 0 0]);
wrap.help    = {
                'This indicates which directions in the volumes the values should wrap around in.  For example, in MRI scans, the images wrap around in the phase encode direction, so (e.g.) the subject''s nose may poke into the back of the subject''s head. These are typically:'
                '    No wrapping - for PET or images that have already                   been spatially transformed. Also the recommended option if                   you are not really sure.'
                '    Wrap in  Y  - for (un-resliced) MRI where phase encoding                   is in the Y direction (voxel space).'
}';
wrap.labels = {
               'No wrap'
               'Wrap X'
               'Wrap Y'
               'Wrap X & Y'
               'Wrap Z'
               'Wrap X & Z'
               'Wrap Y & Z'
               'Wrap X, Y & Z'
}';
wrap.values{1} = double([0 0 0]);
wrap.values{2} = double([1 0 0]);
wrap.values{3} = double([0 1 0]);
wrap.values{4} = double([1 1 0]);
wrap.values{5} = double([0 0 1]);
wrap.values{6} = double([1 0 1]);
wrap.values{7} = double([0 1 1]);
wrap.values{8} = double([1 1 1]);
% ---------------------------------------------------------------------
% weight Weighting
% ---------------------------------------------------------------------
weight         = cfg_files;
weight.tag     = 'weight';
weight.name    = 'Weighting';
weight.val{1} = {};
weight.help    = {'The option of providing a weighting image to weight each voxel of the reference image differently when estimating the realignment parameters.  The weights are proportional to the inverses of the standard deviations. For example, when there is a lot of extra-brain motion - e.g., during speech, or when there are serious artifacts in a particular region of the images.'};
weight.filter = 'image';
weight.ufilter = '.*';
weight.num     = [0 1];
% ---------------------------------------------------------------------
% eoptions Estimation Options
% ---------------------------------------------------------------------
eoptions         = cfg_branch;
eoptions.tag     = 'eoptions';
eoptions.name    = 'Estimation Options';
eoptions.val     = { quality sep fwhm rtm interp wrap weight};
eoptions.help    = {'Various registration options. If in doubt, simply keep the default values.'};
% ---------------------------------------------------------------------
% estimate Realign: Estimate
% ---------------------------------------------------------------------
estimate         = cfg_exbranch;
estimate.tag     = 'estimate';
estimate.name    = 'Realign: Estimate';
estimate.val     = { generic eoptions};
estimate.help    = {
                    'This routine realigns a time-series of images acquired from the same subject using a least squares approach and a 6 parameter (rigid body) spatial transformation/* \cite{friston95a}*/.  The first image in the list specified by the user is used as a reference to which all subsequent scans are realigned. The reference scan does not have to the the first chronologically and it may be wise to chose a "representative scan" in this role.'
                    ''
                    'The aim is primarily to remove movement artefact in fMRI and PET time-series (or more generally longitudinal studies). The headers are modified for each of the input images, such that. they reflect the relative orientations of the data. The details of the transformation are displayed in the results window as plots of translation and rotation. A set of realignment parameters are saved for each session, named rp_*.txt. These can be modelled as confounds within the general linear model/* \cite{friston95a}*/.'
}';
estimate.prog = @spm_run_realign_estimate;
estimate.vout = @vout_estimate;
% ---------------------------------------------------------------------
% data Images
% ---------------------------------------------------------------------
data         = cfg_files;
data.tag     = 'data';
data.name    = 'Images';
data.help    = {'Select scans to reslice to match the first.'};
data.filter = 'image';
data.ufilter = '.*';
data.num     = [1 Inf];
% ---------------------------------------------------------------------
% which Resliced images
% ---------------------------------------------------------------------
which         = cfg_menu;
which.tag     = 'which';
which.name    = 'Resliced images';
which.val{1} = double([2 1]);
which.help    = {
                 'All Images (1..n) :   This reslices all the images - including the first image selected   - which will remain in its original position.'
                 ''
                 'Images 2..n :    Reslices images 2..n only. Useful for if you wish to reslice    (for example) a PET image to fit a structural MRI, without    creating a second identical MRI volume.'
                 ''
                 'All Images + Mean Image :    In addition to reslicing the images, it also creates a mean of the    resliced image.'
                 ''
                 'Mean Image Only :    Creates the mean resliced image only.'
}';
which.labels = {
                ' All Images (1..n)'
                'Images 2..n'
                ' All Images + Mean Image'
                ' Mean Image Only'
}';
which.values{1} = double([2 0]);
which.values{2} = double([1 0]);
which.values{3} = double([2 1]);
which.values{4} = double([0 1]);
% ---------------------------------------------------------------------
% interp Interpolation
% ---------------------------------------------------------------------
interp         = cfg_menu;
interp.tag     = 'interp';
interp.name    = 'Interpolation';
interp.val{1} = double(4);
interp.help    = {'The method by which the images are sampled when being written in a different space.Nearest Neighbour is fastest, but not recommended for image realignment. Bilinear Interpolation is probably OK for PET, but not so suitable for fMRI because higher degree interpolation generally gives better results/* \cite{thevenaz00a,unser93a,unser93b}*/. Although higher degree methods provide better interpolation, but they are slower because they use more neighbouring voxels. Fourier Interpolation/* \cite{eddy96,cox99}*/ is another option, but note that it is only implemented for purely rigid body transformations.  Voxel sizes must all be identical and isotropic.'};
interp.labels = {
                 'Nearest neighbour'
                 'Trilinear'
                 '2nd Degree B-Spline'
                 '3rd Degree B-Spline'
                 '4th Degree B-Spline'
                 '5th Degree B-Spline'
                 '6th Degree B-Spline'
                 '7th Degree B-Spline'
                 'Fourier Interpolation'
}';
interp.values{1} = double(0);
interp.values{2} = double(1);
interp.values{3} = double(2);
interp.values{4} = double(3);
interp.values{5} = double(4);
interp.values{6} = double(5);
interp.values{7} = double(6);
interp.values{8} = double(7);
interp.values{9} = double(Inf);
% ---------------------------------------------------------------------
% wrap Wrapping
% ---------------------------------------------------------------------
wrap         = cfg_menu;
wrap.tag     = 'wrap';
wrap.name    = 'Wrapping';
wrap.val{1} = double([0 0 0]);
wrap.help    = {
                'This indicates which directions in the volumes the values should wrap around in.  For example, in MRI scans, the images wrap around in the phase encode direction, so (e.g.) the subject''s nose may poke into the back of the subject''s head. These are typically:'
                '    No wrapping - for PET or images that have already                   been spatially transformed.'
                '    Wrap in  Y  - for (un-resliced) MRI where phase encoding                   is in the Y direction (voxel space).'
}';
wrap.labels = {
               'No wrap'
               'Wrap X'
               'Wrap Y'
               'Wrap X & Y'
               'Wrap Z'
               'Wrap X & Z'
               'Wrap Y & Z'
               'Wrap X, Y & Z'
}';
wrap.values{1} = double([0 0 0]);
wrap.values{2} = double([1 0 0]);
wrap.values{3} = double([0 1 0]);
wrap.values{4} = double([1 1 0]);
wrap.values{5} = double([0 0 1]);
wrap.values{6} = double([1 0 1]);
wrap.values{7} = double([0 1 1]);
wrap.values{8} = double([1 1 1]);
% ---------------------------------------------------------------------
% mask Masking
% ---------------------------------------------------------------------
mask         = cfg_menu;
mask.tag     = 'mask';
mask.name    = 'Masking';
mask.val{1} = double(1);
mask.help    = {'Because of subject motion, different images are likely to have different patterns of zeros from where it was not possible to sample data. With masking enabled, the program searches through the whole time series looking for voxels which need to be sampled from outside the original images. Where this occurs, that voxel is set to zero for the whole set of images (unless the image format can represent NaN, in which case NaNs are used where possible).'};
mask.labels = {
               'Mask images'
               'Dont mask images'
}';
mask.values{1} = double(1);
mask.values{2} = double(0);
% ---------------------------------------------------------------------
% prefix Filename Prefix
% ---------------------------------------------------------------------
prefix         = cfg_entry;
prefix.tag     = 'prefix';
prefix.name    = 'Filename Prefix';
prefix.val = {'r'};
prefix.help    = {'Specify the string to be prepended to the filenames of the resliced image file(s). Default prefix is ''r''.'};
prefix.strtype = 's';
prefix.num     = [1 Inf];
% ---------------------------------------------------------------------
% roptions Reslice Options
% ---------------------------------------------------------------------
roptions         = cfg_branch;
roptions.tag     = 'roptions';
roptions.name    = 'Reslice Options';
roptions.val     = { which interp wrap mask prefix};
roptions.help    = {'Various reslicing options. If in doubt, simply keep the default values.'};
% ---------------------------------------------------------------------
% write Realign: Reslice
% ---------------------------------------------------------------------
write         = cfg_exbranch;
write.tag     = 'write';
write.name    = 'Realign: Reslice';
write.val     = { data roptions};
write.help    = {'This function reslices a series of registered images such that they match the first image selected voxel-for-voxel. The resliced images are named the same as the originals, except that they are prefixed by ''r''.'};
write.prog = @spm_run_realign_reslice;
write.vout = @vout_reslice;
% ---------------------------------------------------------------------
% data Session
% ---------------------------------------------------------------------
data         = cfg_files;
data.tag     = 'data';
data.name    = 'Session';
data.help    = {'Select scans for this session. In the coregistration step, the sessions are first realigned to each other, by aligning the first scan from each session to the first scan of the first session.  Then the images within each session are aligned to the first image of the session. The parameter estimation is performed this way because it is assumed (rightly or not) that there may be systematic differences in the images between sessions.'};
data.filter = 'image';
data.ufilter = '.*';
data.num     = [1 Inf];
% ---------------------------------------------------------------------
% generic Data
% ---------------------------------------------------------------------
generic         = cfg_repeat;
generic.tag     = 'generic';
generic.name    = 'Data';
generic.help    = {'Add new sessions for this subject. In the coregistration step, the sessions are first realigned to each other, by aligning the first scan from each session to the first scan of the first session.  Then the images within each session are aligned to the first image of the session. The parameter estimation is performed this way because it is assumed (rightly or not) that there may be systematic differences in the images between sessions.'};
generic.values  = { data};
generic.num     = [1 Inf];
% ---------------------------------------------------------------------
% quality Quality
% ---------------------------------------------------------------------
quality         = cfg_entry;
quality.tag     = 'quality';
quality.name    = 'Quality';
quality.val{1} = double(0.900000000000000022);
quality.help    = {'Quality versus speed trade-off.  Highest quality (1) gives most precise results, whereas lower qualities gives faster realignment. The idea is that some voxels contribute little to the estimation of the realignment parameters. This parameter is involved in selecting the number of voxels that are used.'};
quality.strtype = 'r';
quality.num     = [1 1];
quality.extras = double([0 1]);
% ---------------------------------------------------------------------
% sep Separation
% ---------------------------------------------------------------------
sep         = cfg_entry;
sep.tag     = 'sep';
sep.name    = 'Separation';
sep.val{1} = double(4);
sep.help    = {'The separation (in mm) between the points sampled in the reference image.  Smaller sampling distances gives more accurate results, but will be slower.'};
sep.strtype = 'e';
sep.num     = [1 1];
% ---------------------------------------------------------------------
% fwhm Smoothing (FWHM)
% ---------------------------------------------------------------------
fwhm         = cfg_entry;
fwhm.tag     = 'fwhm';
fwhm.name    = 'Smoothing (FWHM)';
fwhm.val{1} = double(5);
fwhm.help    = {
                'The FWHM of the Gaussian smoothing kernel (mm) applied to the images before estimating the realignment parameters.'
                ''
                '    * PET images typically use a 7 mm kernel.'
                ''
                '    * MRI images typically use a 5 mm kernel.'
}';
fwhm.strtype = 'e';
fwhm.num     = [1 1];
% ---------------------------------------------------------------------
% rtm Num Passes
% ---------------------------------------------------------------------
rtm         = cfg_menu;
rtm.tag     = 'rtm';
rtm.name    = 'Num Passes';
rtm.val{1} = double(1);
rtm.help    = {
               'Register to first: Images are registered to the first image in the series. Register to mean:   A two pass procedure is used in order to register the images to the mean of the images after the first realignment.'
               ''
               'PET images are typically registered to the mean. This is because PET data are more noisy than fMRI and there are fewer of them, so time is less of an issue.'
               ''
               'MRI images are typically registered to the first image.  The more accurate way would be to use a two pass procedure, but this probably wouldn''t improve the results so much and would take twice as long to run.'
}';
rtm.labels = {
              'Register to first'
              'Register to mean'
}';
rtm.values{1} = double(0);
rtm.values{2} = double(1);
% ---------------------------------------------------------------------
% interp Interpolation
% ---------------------------------------------------------------------
interp         = cfg_menu;
interp.tag     = 'interp';
interp.name    = 'Interpolation';
interp.val{1} = double(2);
interp.help    = {'The method by which the images are sampled when estimating the optimum transformation. Higher degree interpolation methods provide the better interpolation, but they are slower because they use more neighbouring voxels /* \cite{thevenaz00a,unser93a,unser93b}*/. '};
interp.labels = {
                 'Trilinear (1st Degree)'
                 '2nd Degree B-Spline'
                 '3rd Degree B-Spline '
                 '4th Degree B-Spline'
                 '5th Degree B-Spline'
                 '6th Degree B-Spline'
                 '7th Degree B-Spline'
}';
interp.values{1} = double(1);
interp.values{2} = double(2);
interp.values{3} = double(3);
interp.values{4} = double(4);
interp.values{5} = double(5);
interp.values{6} = double(6);
interp.values{7} = double(7);
% ---------------------------------------------------------------------
% wrap Wrapping
% ---------------------------------------------------------------------
wrap         = cfg_menu;
wrap.tag     = 'wrap';
wrap.name    = 'Wrapping';
wrap.val{1} = double([0 0 0]);
wrap.help    = {
                'This indicates which directions in the volumes the values should wrap around in.  For example, in MRI scans, the images wrap around in the phase encode direction, so (e.g.) the subject''s nose may poke into the back of the subject''s head. These are typically:'
                '    No wrapping - for PET or images that have already                   been spatially transformed. Also the recommended option if                   you are not really sure.'
                '    Wrap in  Y  - for (un-resliced) MRI where phase encoding                   is in the Y direction (voxel space).'
}';
wrap.labels = {
               'No wrap'
               'Wrap X'
               'Wrap Y'
               'Wrap X & Y'
               'Wrap Z'
               'Wrap X & Z'
               'Wrap Y & Z'
               'Wrap X, Y & Z'
}';
wrap.values{1} = double([0 0 0]);
wrap.values{2} = double([1 0 0]);
wrap.values{3} = double([0 1 0]);
wrap.values{4} = double([1 1 0]);
wrap.values{5} = double([0 0 1]);
wrap.values{6} = double([1 0 1]);
wrap.values{7} = double([0 1 1]);
wrap.values{8} = double([1 1 1]);
% ---------------------------------------------------------------------
% weight Weighting
% ---------------------------------------------------------------------
weight         = cfg_files;
weight.tag     = 'weight';
weight.name    = 'Weighting';
weight.val{1} = {};
weight.help    = {'The option of providing a weighting image to weight each voxel of the reference image differently when estimating the realignment parameters.  The weights are proportional to the inverses of the standard deviations. For example, when there is a lot of extra-brain motion - e.g., during speech, or when there are serious artifacts in a particular region of the images.'};
weight.filter = 'image';
weight.ufilter = '.*';
weight.num     = [0 1];
% ---------------------------------------------------------------------
% eoptions Estimation Options
% ---------------------------------------------------------------------
eoptions         = cfg_branch;
eoptions.tag     = 'eoptions';
eoptions.name    = 'Estimation Options';
eoptions.val     = { quality sep fwhm rtm interp wrap weight};
eoptions.help    = {'Various registration options. If in doubt, simply keep the default values.'};
% ---------------------------------------------------------------------
% which Resliced images
% ---------------------------------------------------------------------
which         = cfg_menu;
which.tag     = 'which';
which.name    = 'Resliced images';
which.val{1} = double([2 1]);
which.help    = {
                 'All Images (1..n) :   This reslices all the images - including the first image selected   - which will remain in its original position.'
                 ''
                 'Images 2..n :    Reslices images 2..n only. Useful for if you wish to reslice    (for example) a PET image to fit a structural MRI, without    creating a second identical MRI volume.'
                 ''
                 'All Images + Mean Image :    In addition to reslicing the images, it also creates a mean of the    resliced image.'
                 ''
                 'Mean Image Only :    Creates the mean resliced image only.'
}';
which.labels = {
                ' All Images (1..n)'
                'Images 2..n'
                ' All Images + Mean Image'
                ' Mean Image Only'
}';
which.values{1} = double([2 0]);
which.values{2} = double([1 0]);
which.values{3} = double([2 1]);
which.values{4} = double([0 1]);
% ---------------------------------------------------------------------
% interp Interpolation
% ---------------------------------------------------------------------
interp         = cfg_menu;
interp.tag     = 'interp';
interp.name    = 'Interpolation';
interp.val{1} = double(4);
interp.help    = {'The method by which the images are sampled when being written in a different space.Nearest Neighbour is fastest, but not recommended for image realignment. Bilinear Interpolation is probably OK for PET, but not so suitable for fMRI because higher degree interpolation generally gives better results/* \cite{thevenaz00a,unser93a,unser93b}*/. Although higher degree methods provide better interpolation, but they are slower because they use more neighbouring voxels. Fourier Interpolation/* \cite{eddy96,cox99}*/ is another option, but note that it is only implemented for purely rigid body transformations.  Voxel sizes must all be identical and isotropic.'};
interp.labels = {
                 'Nearest neighbour'
                 'Trilinear'
                 '2nd Degree B-Spline'
                 '3rd Degree B-Spline'
                 '4th Degree B-Spline'
                 '5th Degree B-Spline'
                 '6th Degree B-Spline'
                 '7th Degree B-Spline'
                 'Fourier Interpolation'
}';
interp.values{1} = double(0);
interp.values{2} = double(1);
interp.values{3} = double(2);
interp.values{4} = double(3);
interp.values{5} = double(4);
interp.values{6} = double(5);
interp.values{7} = double(6);
interp.values{8} = double(7);
interp.values{9} = double(Inf);
% ---------------------------------------------------------------------
% wrap Wrapping
% ---------------------------------------------------------------------
wrap         = cfg_menu;
wrap.tag     = 'wrap';
wrap.name    = 'Wrapping';
wrap.val{1} = double([0 0 0]);
wrap.help    = {
                'This indicates which directions in the volumes the values should wrap around in.  For example, in MRI scans, the images wrap around in the phase encode direction, so (e.g.) the subject''s nose may poke into the back of the subject''s head. These are typically:'
                '    No wrapping - for PET or images that have already                   been spatially transformed.'
                '    Wrap in  Y  - for (un-resliced) MRI where phase encoding                   is in the Y direction (voxel space).'
}';
wrap.labels = {
               'No wrap'
               'Wrap X'
               'Wrap Y'
               'Wrap X & Y'
               'Wrap Z'
               'Wrap X & Z'
               'Wrap Y & Z'
               'Wrap X, Y & Z'
}';
wrap.values{1} = double([0 0 0]);
wrap.values{2} = double([1 0 0]);
wrap.values{3} = double([0 1 0]);
wrap.values{4} = double([1 1 0]);
wrap.values{5} = double([0 0 1]);
wrap.values{6} = double([1 0 1]);
wrap.values{7} = double([0 1 1]);
wrap.values{8} = double([1 1 1]);
% ---------------------------------------------------------------------
% mask Masking
% ---------------------------------------------------------------------
mask         = cfg_menu;
mask.tag     = 'mask';
mask.name    = 'Masking';
mask.val{1} = double(1);
mask.help    = {'Because of subject motion, different images are likely to have different patterns of zeros from where it was not possible to sample data. With masking enabled, the program searches through the whole time series looking for voxels which need to be sampled from outside the original images. Where this occurs, that voxel is set to zero for the whole set of images (unless the image format can represent NaN, in which case NaNs are used where possible).'};
mask.labels = {
               'Mask images'
               'Dont mask images'
}';
mask.values{1} = double(1);
mask.values{2} = double(0);
% ---------------------------------------------------------------------
% prefix Filename Prefix
% ---------------------------------------------------------------------
prefix         = cfg_entry;
prefix.tag     = 'prefix';
prefix.name    = 'Filename Prefix';
prefix.val = {'r'};
prefix.help    = {'Specify the string to be prepended to the filenames of the resliced image file(s). Default prefix is ''r''.'};
prefix.strtype = 's';
prefix.num     = [1 Inf];
% ---------------------------------------------------------------------
% roptions Reslice Options
% ---------------------------------------------------------------------
roptions         = cfg_branch;
roptions.tag     = 'roptions';
roptions.name    = 'Reslice Options';
roptions.val     = { which interp wrap mask prefix};
roptions.help    = {'Various reslicing options. If in doubt, simply keep the default values.'};
% ---------------------------------------------------------------------
% estwrite Realign: Estimate & Reslice
% ---------------------------------------------------------------------
estwrite         = cfg_exbranch;
estwrite.tag     = 'estwrite';
estwrite.name    = 'Realign: Estimate & Reslice';
estwrite.val     = { generic eoptions roptions};
estwrite.help    = {
                    'This routine realigns a time-series of images acquired from the same subject using a least squares approach and a 6 parameter (rigid body)spatial transformation/* \cite{friston95a}*/.  The first image in the list specified by the user is used as a reference to which all subsequent scans are realigned. The reference scan does not have to the the first chronologically and it may be wise to chose a "representative scan" in this role.'
                    ''
                    'The aim is primarily to remove movement artefact in fMRI and PET time-series (or more generally longitudinal studies) /* \cite{ashburner97bir}*/. The headers are modified for each of the input images, such that. they reflect the relative orientations of the data. The details of the transformation are displayed in the results window as plots of translation and rotation. A set of realignment parameters are saved for each session, named rp_*.txt. After realignment, the images are resliced such that they match the first image selected voxel-for-voxel. The resliced images are named the same as the originals, except that they are prefixed by ''r''.'
}';
estwrite.prog = @spm_run_realign_estwrite;
estwrite.vout = @vout_estwrite;
% ---------------------------------------------------------------------
% realign Realign
% ---------------------------------------------------------------------
realign         = cfg_repeat;
realign.tag     = 'realign';
realign.name    = 'Realign';
realign.help    = {'Within-subject registration of image time series.'};
realign.values  = { estimate write estwrite};
realign.num     = [1 Inf];

%------------------------------------------------------------------------
 
%------------------------------------------------------------------------
function dep = vout_reslice(job)
if job.roptions.which(1) > 0
    dep(1)            = cfg_dep;
    dep(1).sname      = 'Resliced Images';
    dep(1).src_output = substruct('.','rfiles');
    dep(1).tgt_spec   = cfg_findspec({{'class','cfg_files','strtype','e'}});
end;
if job.roptions.which(2),
    if exist('dep','var')
        dep(end+1) = cfg_dep;
    else
        dep = cfg_dep;
    end;
    dep(end).sname      = 'Mean Image';
    dep(end).src_output = substruct('.','rmean');
    dep(end).tgt_spec   = cfg_findspec({{'class','cfg_files','strtype','e'}});
end;

%------------------------------------------------------------------------
 
%------------------------------------------------------------------------
function dep = vout_estimate(job)
for k=1:numel(job.data)
    cdep(1)            = cfg_dep;
    cdep(1).sname      = sprintf('Realigned Images (Sess %d)', k);
    cdep(1).src_output = substruct('.','sess', '()',{k}, '.','cfiles');
    cdep(1).tgt_spec   = cfg_findspec({{'class','cfg_files','strtype','e'}});
    cdep(2)            = cfg_dep;
    cdep(2).sname      = sprintf('Realignment Param File (Sess %d)', k);
    cdep(2).src_output = substruct('.','sess', '()',{k}, '.','rpfile');
    cdep(2).tgt_spec   = cfg_findspec({{'class','cfg_files','strtype','e'}});
    if k == 1
        dep = cdep;
    else
        dep = [dep cdep];
    end;
end;

%------------------------------------------------------------------------
 
%------------------------------------------------------------------------
function dep = vout_estwrite(job)
for k=1:numel(job.data)
    cdep(1)            = cfg_dep;
    cdep(1).sname      = sprintf('Realigned Images (Sess %d)', k);
    cdep(1).src_output = substruct('.','sess', '()',{k}, '.','cfiles');
    cdep(1).tgt_spec   = cfg_findspec({{'class','cfg_files','strtype','e'}});
    cdep(2)            = cfg_dep;
    cdep(2).sname      = sprintf('Realignment Param File (Sess %d)', k);
    cdep(2).src_output = substruct('.','sess', '()',{k}, '.','rpfile');
    cdep(2).tgt_spec   = cfg_findspec({{'class','cfg_files','strtype','e'}});
    if job.roptions.which(1) > 0
        cdep(3)            = cfg_dep;
        cdep(3).sname      = sprintf('Resliced Images (Sess %d)', k);
        cdep(3).src_output = substruct('.','sess', '()',{k}, '.','rfiles');
        cdep(3).tgt_spec   = cfg_findspec({{'class','cfg_files','strtype','e'}});
    end;
    if k == 1
        dep = cdep;
    else
        dep = [dep cdep];
    end;
end;
if job.roptions.which(2),
    if exist('dep','var')
        dep(end+1) = cfg_dep;
    else
        dep = cfg_dep;
    end;
    dep(end).sname      = 'Mean Image';
    dep(end).src_output = substruct('.','rmean');
    dep(end).tgt_spec   = cfg_findspec({{'class','cfg_files','strtype','e'}});
end;

