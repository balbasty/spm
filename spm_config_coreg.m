function opts = spm_config_coreg
% Configuration file for coregister jobs
%_______________________________________________________________________
% %W% %E%
% DRG CS-RCS: $Id: spm_config_coreg.m,v 1.1 2005-02-08 21:06:31-06 drg Exp drg $

%_______________________________________________________________________

w = spm_jobman('HelpWidth');

%_______________________________________________________________________

ref.type = 'files';
ref.name = 'Reference Image';
ref.tag  = 'ref';
ref.filter = 'image';
ref.num  = 1;
ref.help = spm_justify(w,...
'This is the image that is assumed to remain stationary (sometimes',...
'known as the target or template image), while the source image',...
'is moved to match it.');

%------------------------------------------------------------------------

source.type = 'files';
source.name = 'Source Image';
source.tag  = 'source';
source.filter = 'image';
source.num  = 1;
source.help = spm_justify(w,...
'This is the image that is jiggled about to best match the reference.');

%------------------------------------------------------------------------

other.type = 'files';
other.name = 'Other Images';
other.tag  = 'other';
other.filter = 'image';
other.num  = [0 Inf];
other.val  = {''};
other.help = spm_justify(w,...
'These are any images that need to remain in alignment with the',...
'source image.');

%------------------------------------------------------------------------

cost_fun.type = 'menu';
cost_fun.name = 'Objective Function';
cost_fun.tag  = 'cost_fun';
cost_fun.labels = {'Mutual Information','Normalised Mutual Information',...
'Entropy Correlation Coefficient','Normalised Cross Correlation'};
cost_fun.values = {'mi','nmi','ecc','ncc'};
cost_fun.def  = 'coreg.estimate.cost_fun';
cost_fun.help = {...
'Registration involves finding parameters that either maximise or',...
'minimise some objective function.',...
'',...
'For inter-modal registration, use one of the following objective',...
'functions:',...
'    Mutual Information',...
'    Normalised Mutual Information',...
'    Entropy Correlation Coefficient',...
'For within modality, you could use:',...
'    Normalised Cross Correlation',...
'',...
'References:',...
' Mutual Information',...
'  * Collignon, Maes, Delaere, Vandermeulen, Suetens & Marchal (1995).',...
'    "Automated multi-modality image registration based on information theory".',...
'    In Bizais, Barillot & Di Paola, editors, Proc. Information Processing',...
'    in Medical Imaging, pages 263--274, Dordrecht, The Netherlands, 1995.',...
'    Kluwer Academic Publishers.',...
'  * Wells III, Viola, Atsumi, Nakajima & Kikinis (1996).',...
'    "Multi-modal volume registration by maximisation of mutual information".',...
'    Medical Image Analysis, 1(1):35-51, 1996.',...
'',...
' Entropy Correlation Coefficient',...
'  * F Maes, A Collignon, D Vandermeulen, G Marchal & P Suetens (1997).',...
'    "Multimodality image registration by maximisation of mutual',...
'    information". IEEE Transactions on Medical Imaging 16(2):187-198',...
'',...
' Normalised Mutual Information',...
'  * Studholme,  Hill & Hawkes (1998).',...
'    "A normalized entropy measure of 3-D medical image alignment".',...
'    in Proc. Medical Imaging 1998, vol. 3338, San Diego, CA, pp. 132-143.'};

%------------------------------------------------------------------------

sep.type = 'entry';
sep.name = 'Separation';
sep.tag  = 'sep';
sep.num  = [1 Inf];
sep.strtype = 'e';
sep.def  = 'coreg.estimate.sep';
sep.help = spm_justify(w,...
'The average distance between sampled points (in mm).  Can be a vector',...
'to allow a coarse registration followed by increasingly fine ones.');

%------------------------------------------------------------------------

tol.type = 'entry';
tol.name = 'Tolerences';
tol.tag = 'tol';
tol.num = [1 6];
tol.strtype = 'e';
tol.def = 'coreg.estimate.tol';
tol.help = spm_justify(w,...
'The accuracy for each parameter.  Iterations stop when differences',...
'between sucessive estimates are less than the required tolerence.');

%------------------------------------------------------------------------

fwhm.type = 'entry';
fwhm.name = 'Histogram Smoothing';
fwhm.tag  = 'fwhm';
fwhm.num  = [1 2];
fwhm.strtype = 'e';
fwhm.def = 'coreg.estimate.fwhm';
fwhm.help = spm_justify(w,...
'Gaussian smoothing to apply to the 256x256 joint histogram. Other',...
'information theoretic coregistration methods use fewer bins, but',...
'Gaussian smoothing seems to be more elegant.');

%------------------------------------------------------------------------

eoptions.type = 'branch';
eoptions.name = 'Estimation Options';
eoptions.tag  = 'eoptions';
eoptions.val  = {cost_fun,sep,tol,fwhm};
eoptions.help = {'Various registration options.'};

%------------------------------------------------------------------------

est.type = 'branch';
est.name = 'Coreg: Estimate';
est.tag  = 'estimate';
est.val  = {ref,source,other,eoptions};
est.prog = @estimate;
p1 = spm_justify(w,...
'The registration method used here is based on work by Collignon et al.',...
'The original interpolation method described in this paper has been',...
'changed in order to give a smoother cost function.  The images are',...
'also smoothed slightly, as is the histogram.  This is all in order to',...
'make the cost function as smooth as possible, to give faster',...
'convergence and less chance of local minima.');
p2 = spm_justify(w,...
'At the end of coregistration, the voxel-to-voxel affine transformation',...
'matrix is displayed, along with the histograms for the images in the',...
'original orientations, and the final orientations.  The registered',...
'images are displayed at the bottom.');
p3 = spm_justify(w,...
'Registration parameters are stored in the ".mat" files of the "source"',...
'and the "other" images.');

est.help = {p1{:},'',p2{:},'',p3{:},'',...
'Reference:',...
'  * A Collignon, F Maes, D Delaere, D Vandermeulen, P Suetens & G Marchal',...
'    (1995) "Automated Multi-modality Image Registration Based On',...
'    Information Theory". In the proceedings of Information Processing in',...
'    Medical Imaging (1995).  Y. Bizais et al. (eds.).  Kluwer Academic',...
'    Publishers.',...
'  * Press, Teukolsky, Vetterling & Flannery (1992).',...
'    "Numerical Recipes in C (Second Edition)".',...
'    Published by Cambridge.'};

%------------------------------------------------------------------------

interp.type = 'menu';
interp.name = 'Interpolation';
interp.tag  = 'interp';
interp.labels = {'Nearest neighbour','Trilinear','2nd Degree B-spline',...
'3rd Degree B-Spline','4th Degree B-Spline','5th Degree B-Spline',...
'6th Degree B-Spline','7th Degree B-Spline'};
interp.values = {0,1,2,3,4,5,6,7};
interp.def  = 'coreg.write.interp';
interp.help = {...
'The method by which the images are sampled when being written in a',...
'different space.',...
'    Nearest Neighbour',...
'    - Fastest, but not normally recommended.',...
'    Bilinear Interpolation',...
'    - OK for PET, or realigned fMRI.',...
'    B-spline Interpolation',...
'    - Better quality (but slower) interpolation, especially',...
'      with higher degree splines.  Do not use B-splines when',...
'      there is any region of NaN or Inf in the images.',...
'',...
'References:',...
'    * M. Unser, A. Aldroubi and M. Eden.',...
'      "B-Spline Signal Processing: Part I-Theory,"',...
'      IEEE Transactions on Signal Processing 41(2):821-832 (1993).',...
'    * M. Unser, A. Aldroubi and M. Eden.',...
'      "B-Spline Signal Processing: Part II-Efficient Design and',...
'      Applications,"',...
'      IEEE Transactions on Signal Processing 41(2):834-848 (1993).',...
'    * M. Unser.',...
'      "Splines: A Perfect Fit for Signal and Image Processing,"',...
'      IEEE Signal Processing Magazine, 16(6):22-38 (1999)',...
'    * P. Thevenaz and T. Blu and M. Unser.',...
'      "Interpolation Revisited"',...
'      IEEE Transactions on Medical Imaging 19(7):739-758 (2000).',...
};

%------------------------------------------------------------------------

wrap.type = 'menu';
wrap.name = 'Wrapping';
wrap.tag  = 'wrap';
wrap.labels = {'No wrap','Wrap X','Wrap Y','Wrap X & Y','Wrap Z',...
'Wrap X & Z','Wrap Y & Z','Wrap X, Y & Z'};
wrap.values = {[0 0 0],[1 0 0],[0 1 0],[1 1 0],[0 0 1],[1 0 1],[0 1 1],[1 1 1]};
wrap.def    = 'coreg.write.wrap';
wrap.help = {...
'These are typically:',...
'    No wrapping - for PET or images that have already',...
'                  been spatially transformed.',...
'    Wrap in  Y  - for (un-resliced) MRI where phase encoding',...
'                  is in the Y direction (voxel space).'};

%------------------------------------------------------------------------

mask.type = 'menu';
mask.name = 'Masking';
mask.tag  = 'mask';
mask.labels = {'Mask images','Dont mask images'};
mask.values = {1,0};
mask.def    = 'coreg.write.mask';
mask.help = spm_justify(w,...
'Because of subject motion, different images are likely to have different',...
'patterns of zeros from where it was not possible to sample data.',...
'With masking enabled, the program searches through the whole time series',...
'looking for voxels which need to be sampled from outside the original',...
'images. Where this occurs, that voxel is set to zero for the whole set',...
'of images (unless the image format can represent NaN, in which case',...
'NaNs are used where possible).');

%------------------------------------------------------------------------

roptions.type = 'branch';
roptions.name = 'Reslice Options';
roptions.tag  = 'roptions';
roptions.val  = {interp,wrap,mask};
roptions.help = {'Various reslicing options.'};

%------------------------------------------------------------------------

estwrite.type = 'branch';
estwrite.name = 'Coreg: Estimate & Reslice';
estwrite.tag  = 'estwrite';
estwrite.val  = {ref,source,other,eoptions,roptions};
estwrite.prog = @estimate_reslice;
estwrite.vfiles = @vfiles_estwrite;
p1 = spm_justify(w,...
'The registration method used here is based on work by Collignon et al.',...
'The original interpolation method described in this paper has been',...
'changed in order to give a smoother cost function.  The images are',...
'also smoothed slightly, as is the histogram.  This is all in order to',...
'make the cost function as smooth as possible, to give faster',...
'convergence and less chance of local minima.');
p2 = spm_justify(w,...
'At the end of coregistration, the voxel-to-voxel affine transformation',...
'matrix is displayed, along with the histograms for the images in the',...
'original orientations, and the final orientations.  The registered',...
'images are displayed at the bottom.');
p3 = spm_justify(w,...
'Registration parameters are stored in the ".mat" files of the "source"',...
'and the "other" images. These images are also resliced to match the',...
'source image voxel-for-voxel. The resliced images are named the same as',...
'the originals except that they are prefixed by ''r''.');
estwrite.help = {p1{:},'',p2{:},'',p3{:},'',...
'Reference:',...
'  * A Collignon, F Maes, D Delaere, D Vandermeulen, P Suetens & G Marchal',...
'    (1995) "Automated Multi-modality Image Registration Based On',...
'    Information Theory". In the proceedings of Information Processing in',...
'    Medical Imaging (1995).  Y. Bizais et al. (eds.).  Kluwer Academic',...
'    Publishers.',...
'  * Press, Teukolsky, Vetterling & Flannery (1992).',...
'    "Numerical Recipes in C (Second Edition)".',...
'    Published by Cambridge.'};

%------------------------------------------------------------------------

ref.type = 'files';
ref.name = 'Image Defining Space';
ref.tag  = 'ref';
ref.filter = 'image';
ref.num  = 1;
ref.help = spm_justify(w,...
'This is analagous to the reference image.  Images are resliced to match',...
'this image (providing they have been coregistered first).');

%------------------------------------------------------------------------
 
source.type = 'files';
source.name = 'Images to Reslice';
source.tag  = 'source';
source.filter = 'image';
source.num  = Inf;
source.help = spm_justify(w,...
'These images are resliced to the same dimensions, voxel sizes,',...
'orientation etc as the space defining image.');

%------------------------------------------------------------------------

write.type = 'branch';
write.name = 'Coreg: Reslice';
write.tag  = 'write';
write.val  = {ref,source,roptions};
write.prog = @reslice;
write.vfiles = @vfiles_write;
write.help = spm_justify(w,...
'Reslice images to match voxel-for-voxel with an image defining',...
'some space. The resliced images are named the same as the originals',...
'except that they are prefixed by ''r''.');

%------------------------------------------------------------------------

opts.type = 'repeat';
opts.name = 'Coreg';
opts.tag  = 'coreg';
opts.values = {est,write,estwrite};
opts.modality = {'PET','FMRI','VBM'};
p1 = spm_justify(w,...
'Within-subject registration using a rigid-body model.',...
'A rigid-body transformation (in 3D) can be parameterised by three',...
'translations and three rotations about the different axes.');
p2 = spm_justify(w,...
'You get the options of estimating the transformation, reslicing images',...
'according to some rigid-body transformations, or estimating and',...
'applying rigid-body transformations.');
opts.help = {p1{:},'',p2{:}};

return;
%------------------------------------------------------------------------

%------------------------------------------------------------------------
function estimate(varargin)
job = varargin{1};
%disp(job);
%disp(job.eoptions);

x  = spm_coreg(strvcat(job.ref), strvcat(job.source),job.eoptions);
M  = inv(spm_matrix(x));
PO = strvcat(strvcat(job.source),strvcat(job.other));
MM = zeros(4,4,size(PO,1));
for j=1:size(PO,1),
	MM(:,:,j) = spm_get_space(deblank(PO(j,:)));
end;
for j=1:size(PO,1),
	spm_get_space(deblank(PO(j,:)), M*MM(:,:,j));
end;

return;
%------------------------------------------------------------------------

%------------------------------------------------------------------------
function reslice(varargin)
job = varargin{1};

P            = strvcat(strvcat(job.ref),strvcat(job.source));
flags.mask   = job.roptions.mask;
flags.mean   = 0;
flags.interp = job.roptions.interp;
flags.which  = 1;
flags.wrap   = job.roptions.wrap;

spm_reslice(P,flags);

return;
%------------------------------------------------------------------------

%------------------------------------------------------------------------
function estimate_reslice(varargin)
job = varargin{1};
%disp(job);
%disp(job.eoptions);
%disp(job.roptions);

job.ref    = strvcat(job.ref);
job.source = strvcat(job.source);
job.other  = strvcat(job.other);

x  = spm_coreg(job.ref, job.source,job.eoptions);
M  = inv(spm_matrix(x));
PO = strvcat(job.source,job.other);
MM = zeros(4,4,size(PO,1));
for j=1:size(PO,1),
        MM(:,:,j) = spm_get_space(deblank(PO(j,:)));
end;
for j=1:size(PO,1),
        spm_get_space(deblank(PO(j,:)), M*MM(:,:,j));
end;

P            = strvcat(job.ref,job.source,job.other);
flags.mask   = job.roptions.mask;
flags.mean   = 0;
flags.interp = job.roptions.interp;
flags.which  = 1;
flags.wrap   = job.roptions.wrap;

spm_reslice(P,flags);

return;
%------------------------------------------------------------------------

%------------------------------------------------------------------------
function vf = vfiles_write(varargin)
job = varargin{1};
vf  = cell(size(job.source));
for i=1:numel(job.source),
    [pth,nam,ext,num] = spm_fileparts(job.source{i});
    vf{i} = fullfile(pth,['r' nam '.img' num]);
end;
%------------------------------------------------------------------------

%------------------------------------------------------------------------
function vf = vfiles_estwrite(varargin)
job = varargin{1};
P   = {job.source{:},job.other{:}};
vf  = cell(size(P));
for i=1:numel(P),
    [pth,nam,ext,num] = spm_fileparts(P{i});
    vf{i} = fullfile(pth,['r' nam '.img' num]);
end;


