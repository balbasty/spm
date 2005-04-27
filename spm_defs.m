function spm_defs(job)
% Various deformation field utilities.
% FORMAT spm_defs(job)
% job - a job created via spm_config_defs.m and spm_jobman.m
%
% See spm_config_defs.m for more information.
%_______________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% John Ashburner
% $Id$

[Def,mat] = get_comp(job.comp);
save_def(Def,mat,strvcat(job.ofname));
apply_def(Def,mat,strvcat(job.fnames));
%_______________________________________________________________________

%_______________________________________________________________________
function [Def,mat] = get_comp(job)
% Return the composition of a number of deformation fields.

if isempty(job),
    error('Empty list of jobs in composition');
end;
[Def,mat] = get_job(job{1});
for i=2:numel(job),
fprintf('%d\n',i);
    Def1 = Def;
    mat1 = mat;
    [Def,mat] = get_job(job{i});
    M    = inv(mat1);
    for j=1:size(Def{1},3)
        d0    = {double(Def{1}(:,:,j)), double(Def{2}(:,:,j)),double(Def{3}(:,:,j))};
        d{1}  = M(1,1)*d0{1}+M(1,2)*d0{2}+M(1,3)*d0{3}+M(1,4);
        d{2}  = M(2,1)*d0{1}+M(2,2)*d0{2}+M(2,3)*d0{3}+M(2,4);
        d{3}  = M(3,1)*d0{1}+M(3,2)*d0{2}+M(3,3)*d0{3}+M(3,4);
        Def{1}(:,:,j) = single(spm_sample_vol(Def1{1},d{:},[1,NaN]));
        Def{2}(:,:,j) = single(spm_sample_vol(Def1{2},d{:},[1,NaN]));
        Def{3}(:,:,j) = single(spm_sample_vol(Def1{3},d{:},[1,NaN]));

    end;
    subplot(3,3,i);imagesc(Def{3}(:,:,20));drawnow;
end;
%_______________________________________________________________________

%_______________________________________________________________________
function [Def,mat] = get_job(job)
% Determine what is required, and pass the relevant bit of the
% job out to the appropriate function.

fn = fieldnames(job);
fn = fn{1};
switch fn
case {'comp'}
    [Def,mat] = get_comp(job.(fn));
case {'def'}
    [Def,mat] = get_def(job.(fn));
case {'sn2def'}
    [Def,mat] = get_sn2def(job.(fn));
case {'inv'}
    [Def,mat] = get_inv(job.(fn));
otherwise
    error('Unrecognised job type');
end;
%_______________________________________________________________________

%_______________________________________________________________________
function [Def,mat] = get_sn2def(job)
% Convert a SPM _sn.mat file into a deformation field, and return it.

vox = job.vox;
bb  = job.bb;
sn  = load(job.matname{1});

[bb0,vox0] = bbvox_from_V(sn.VG(1));

if any(~finite(vox)), vox = vox0; end;
if any(~finite(bb)),  bb  = bb0;  end;
bb  = sort(bb);
vox = abs(vox);

% Adjust bounding box slightly - so it rounds to closest voxel.
bb(:,1) = round(bb(:,1)/vox(1))*vox(1);
bb(:,2) = round(bb(:,2)/vox(2))*vox(2);
bb(:,3) = round(bb(:,3)/vox(3))*vox(3);

M   = sn.VG(1).mat;
vxg = sqrt(sum(M(1:3,1:3).^2));
ogn = M\[0 0 0 1]';
ogn = ogn(1:3)';

% Convert range into range of voxels within template image
x   = (bb(1,1):vox(1):bb(2,1))/vxg(1) + ogn(1);
y   = (bb(1,2):vox(2):bb(2,2))/vxg(2) + ogn(2);
z   = (bb(1,3):vox(3):bb(2,3))/vxg(3) + ogn(3);

og  = -vxg.*ogn;
of  = -vox.*(round(-bb(1,:)./vox)+1);
M1  = [vxg(1) 0 0 og(1) ; 0 vxg(2) 0 og(2) ; 0 0 vxg(3) og(3) ; 0 0 0 1];
M2  = [vox(1) 0 0 of(1) ; 0 vox(2) 0 of(2) ; 0 0 vox(3) of(3) ; 0 0 0 1];
mat = sn.VG(1).mat*inv(M1)*M2;
dim = [length(x) length(y) length(z)];

[X,Y] = ndgrid(x,y);

st = size(sn.Tr);

if (prod(st) == 0),
    affine_only = true;
    basX = 0; tx = 0;
    basY = 0; ty = 0;
    basZ = 0; tz = 0;
else,
    affine_only = false;
    basX = spm_dctmtx(sn.VG(1).dim(1),st(1),x-1);
    basY = spm_dctmtx(sn.VG(1).dim(2),st(2),y-1);
    basZ = spm_dctmtx(sn.VG(1).dim(3),st(3),z-1);
end,

Def = single(0);
Def(numel(x),numel(y),numel(z)) = 0;
Def = {Def; Def; Def};

for j=1:length(z)
    if (~affine_only)
        tx = reshape( reshape(sn.Tr(:,:,:,1),st(1)*st(2),st(3)) *basZ(j,:)', st(1), st(2) );
        ty = reshape( reshape(sn.Tr(:,:,:,2),st(1)*st(2),st(3)) *basZ(j,:)', st(1), st(2) );
        tz = reshape( reshape(sn.Tr(:,:,:,3),st(1)*st(2),st(3)) *basZ(j,:)', st(1), st(2) );

        X1 = X    + basX*tx*basY';
        Y1 = Y    + basX*ty*basY';
        Z1 = z(j) + basX*tz*basY';
    end

    Mult = sn.VF.mat*sn.Affine;
    if (~affine_only)
        X2= Mult(1,1)*X1 + Mult(1,2)*Y1 + Mult(1,3)*Z1 + Mult(1,4);
        Y2= Mult(2,1)*X1 + Mult(2,2)*Y1 + Mult(2,3)*Z1 + Mult(2,4);
        Z2= Mult(3,1)*X1 + Mult(3,2)*Y1 + Mult(3,3)*Z1 + Mult(3,4);
    else
        X2= Mult(1,1)*X + Mult(1,2)*Y + (Mult(1,3)*z(j) + Mult(1,4));
        Y2= Mult(2,1)*X + Mult(2,2)*Y + (Mult(2,3)*z(j) + Mult(2,4));
        Z2= Mult(3,1)*X + Mult(3,2)*Y + (Mult(3,3)*z(j) + Mult(3,4));
    end

    Def{1}(:,:,j) = single(X2);
    Def{2}(:,:,j) = single(Y2);
    Def{3}(:,:,j) = single(Z2);
end;
%_______________________________________________________________________

%_______________________________________________________________________
function [bb,vx] = bbvox_from_V(V)
% Return the default bounding box for an image volume

vx = sqrt(sum(V.mat(1:3,1:3).^2));
o  = V.mat\[0 0 0 1]';
o  = o(1:3)';
bb = [-vx.*(o-1) ; vx.*(V.dim(1:3)-o)];
return;
%_______________________________________________________________________

%_______________________________________________________________________
function [Def,mat] = get_def(job)
% Load a deformation field saved as an image

P      = [repmat(job{:},3,1), [',1,1';',1,2';',1,3']];
V      = spm_vol(P);
Def    = cell(3,1);
Def{1} = spm_load_float(V(1));
Def{2} = spm_load_float(V(2));
Def{3} = spm_load_float(V(3));
%_______________________________________________________________________

%_______________________________________________________________________
function [Def,mat] = get_inv(job)
% Invert a deformation field (derived from a composition of deformations)

VT          = spm_vol(job.space{:});
[Def0,mat0] = get_comp(job.comp);
M0      = mat0;
M1      = inv(VT.mat);
M0(4,:) = [0 0 0 1];
M1(4,:) = [0 0 0 1];
[Def{1},Def{2},Def{3}]    = spm_invdef(Def0{:},VT.dim(1:3),M1,M0);
mat         = VT.mat;
%_______________________________________________________________________

%_______________________________________________________________________
function save_def(Def,mat,ofname)
% Save a deformation field as an image

if isempty(ofname), return; end;

fname = ['y_' ofname '.nii'];
dim   = [size(Def{1},1) size(Def{1},2) size(Def{1},3) 1 3];
dtype = 'FLOAT32-BE';
off   = 0;
scale = 1;
inter = 0;
dat   = file_array(fname,dim,dtype,off,scale,inter);

N      = nifti;
N.dat  = dat;
N.mat  = mat;
N.mat0 = mat;
N.mat_intent  = 'Aligned';
N.mat0_intent = 'Aligned';
N.intent.code = 'DISPLACEMENT';
N.intent.name = 'Deformation';
N.descrip = 'Deformation field';
create(N);
N.dat(:,:,:,1,1) = Def{1};
N.dat(:,:,:,1,2) = Def{2};
N.dat(:,:,:,1,3) = Def{3};
return;
%_______________________________________________________________________

%_______________________________________________________________________
function apply_def(Def,mat,fnames)
% Warp an image or series of images according to a deformation field

for i=1:size(fnames,1),
    V = spm_vol(fnames(i,:));
    M = inv(V.mat);
    [pth,nam,ext,num] = spm_fileparts(fnames(i,:));
    ofname = ['w',nam,ext];
    Vo = struct('fname',ofname,...
                'dim',[size(Def{1},1) size(Def{1},2) size(Def{1},3)],...
                'dt',V.dt,...
                'pinfo',V.pinfo,...
                'mat',mat,...
                'n',V.n,...
                'descrip',V.descrip);
    Vo = spm_create_vol(Vo);
    for j=1:size(Def{1},3)
        d0    = {double(Def{1}(:,:,j)), double(Def{2}(:,:,j)),double(Def{3}(:,:,j))};
        d{1}  = M(1,1)*d0{1}+M(1,2)*d0{2}+M(1,3)*d0{3}+M(1,4);
        d{2}  = M(2,1)*d0{1}+M(2,2)*d0{2}+M(2,3)*d0{3}+M(2,4);
        d{3}  = M(3,1)*d0{1}+M(3,2)*d0{2}+M(3,3)*d0{3}+M(3,4);
        dat   = spm_sample_vol(V,d{:},1);
        Vo    = spm_write_plane(Vo,dat,j);
    end;
end;
return;
