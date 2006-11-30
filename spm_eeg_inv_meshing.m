function D = spm_eeg_inv_meshing(S)

%=======================================================================
% Apply the inverse spatial deformation to the template mesh
% to obtain the individual cortical mesh
% save the individual .mat tesselation of the chosen size
%
% FORMAT D = spm_eeg_inv_meshing(S)
% Input:
% S		    - input data struct (optional)
% Output:
% D			- same data struct including the new files and parameters
%=======================================================================
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% Jeremie Mattout & Christophe Phillips
% $Id: spm_eeg_inv_meshing.m 701 2006-11-30 12:37:39Z james $

spm_defaults

try
    D = S;
catch
    D = spm_select(1, '.mat', 'Select EEG/MEG mat file');
    D = spm_eeg_ldata(D);
end

try
    val = D.val;
catch
    val = length(D.inv);
end

if isempty(D.inv{val}.mesh.sMRI)
    D.inv{val}.mesh.sMRI   = spm_select(1,'image','Select subject sMRI');
end

if isempty(D.inv{val}.mesh.def)
    D.inv{val}.mesh.def    = spm_select(1,'mat','Select deformation');
end

if isempty(D.inv{val}.mesh.invdef)
    D.inv{val}.mesh.invdef = spm_select(1,'mat','Select inv deformation');
end

if isempty(D.inv{val}.mesh.Msize)
    Msize = spm_input('Mesh size (vertices)','+1','3000|4000|5000|7200',[1 2 3 4]);
    D.inv{val}.mesh.Msize = Msize;
else
    Msize = D.inv{val}.mesh.Msize;
end

switch Msize
    case 1
        template_mesh = 'wmeshTemplate_3004d.mat';
    case 2
        template_mesh = 'wmeshTemplate_4004d.mat';
    case 3
        template_mesh = 'wmeshTemplate_5004d.mat';
    case 4
        template_mesh = 'wmeshTemplate_7204d.mat';
end

% Compute the inner-skull and scalp meshes
%--------------------------------------------------------------------------

D        = spm_eeg_inv_getmasks(D);
D        = spm_eeg_inv_getmeshes(D);

% Compute the cortex mesh from the template
%--------------------------------------------------------------------------
Tmesh                  = load(template_mesh);
D.inv{val}.mesh.Ctx_Nv = length(Tmesh.vert);
D.inv{val}.mesh.Ctx_Nf = length(Tmesh.face);

vert     = spm_get_orig_coord(Tmesh.vert,D.inv{val}.mesh.def);
face     = Tmesh.face;
normal   = spm_eeg_inv_normals(vert,face);
Mdist    = spm_eeg_inv_meshdist(vert,face);

[pth,nam,ext] = spm_fileparts(D.inv{val}.mesh.sMRI);

meshname = [nam '_CortexMesh_' num2str(D.inv{val}.mesh.Ctx_Nv) '.mat'];
D.inv{val}.mesh.tess_ctx = fullfile(pth,meshname);

distname = [nam '_CortexGeoDist_' num2str(D.inv{val}.mesh.Ctx_Nv) '.mat'];
D.inv{val}.mesh.CtxGeoDist = fullfile(pth,distname);

if spm_matlab_version_chk('7') >= 0
    save(D.inv{val}.mesh.tess_ctx,'-V6','vert','face','normal');
    save(D.inv{val}.mesh.CtxGeoDist,'-V6','Mdist');
else
    save(D.inv{val}.mesh.tess_ctx,'vert','face','normal');
    save(D.inv{val}.mesh.CtxGeoDist,'Mdist');
end

save(fullfile(D.path, D.fname), 'D');

spm('Pointer','Arrow');

%==========================================================================
function normal = spm_eeg_inv_normals(vert,face)

m = struct('Vertices',vert,'Faces',face);

h = figure('Visible','off');
n = get(patch(m),'VertexNormals');
close(h);

f = sqrt(sum(n.^2,2));

I = find(f == 0);
for i = 1:length(I)
    n(I(i)) = n(I(i) - 1);
end

f = sqrt(sum(n.^2,2));

normal(:,1) = n(:,1)./f;
normal(:,2) = n(:,2)./f;
normal(:,3) = n(:,3)./f;

clear m f

return
%==========================================================================

%==========================================================================
function Mdist = spm_eeg_inv_meshdist(vert,face)
% Efficient computation of the 2nd order distance matrix of a triangulated
% irregular mesh, based on the cortical neighbourhood (geodesic distance)
% and not on the euclidian distance
%
% Inspired by function mesh_laplacian.m by Darren Weber
% from the bioelectromagnetism matlab toolbox
% see http://eeg.sourceforge.net/

Nv = length(vert);
Nf = length(face);

edge  = sparse(Nv,Nv);
for i = 1:size(face,1);
    Diff  = [vert(face(i,[1 2 3]),:) - vert(face(i,[2 3 1]),:)];
    EuclD = sqrt( sum(Diff.^2, 2) );

    edge(face(i,1),face(i,2)) = EuclD(1);
    edge(face(i,2),face(i,3)) = EuclD(2);
    edge(face(i,3),face(i,1)) = EuclD(3);

    edge(face(i,2),face(i,1)) = EuclD(1);
    edge(face(i,3),face(i,2)) = EuclD(2);
    edge(face(i,1),face(i,3)) = EuclD(3);
end
clear face vert

Mdist = edge;
for i = 1:Nv
    a          = find(edge(i,:));
    [b,c]      = find(edge(a,:));
    Mdist(i,c) = Mdist(i,a(b)) + diag(Mdist(a(b),c))';
    Mdist(c,i) = Mdist(i,c)';
end
clear edge

return
%==========================================================================
