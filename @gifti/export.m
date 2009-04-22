function s = export(this,target)
% Export a GIfTI object into specific MATLAB struct
% FORMAT s = export(this,target)
% this   - GIfTI object
% target - string describing target output [default: Matlab]
% s      - a structure containing public fields of the object
%__________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% Guillaume Flandin
% $Id: export.m 3081 2009-04-22 20:15:38Z guillaume $

if numel(this) > 1, warning('Only handle scalar objects yet.'); end

if nargin <= 1, target = 'Matlab'; end

switch lower(target)
    case 'matlab'
        s = struct(this);
        
    case 'patch'
        if isfield(this,'vertices')
            s.vertices = subsref(this, substruct('.', 'vertices'));
        end
        if isfield(this,'faces')
            s.faces = subsref(this, substruct('.', 'faces'));
        end
        if isfield(this,'cdata')  
            s.facevertexcdata = subsref(this, substruct('.', 'cdata'));
        end
        try, s; catch, s = struct([]); end
        
    case {'fieldtrip', 'ft'}
        s = struct('tri',[], 'pnt',[]);
        if isfield(this,'vertices')
            s.pnt = double(subsref(this, substruct('.', 'vertices')));
        end
        if  isfield(this,'faces')  
            s.tri = double(subsref(this, substruct('.', 'faces')));
        end
        
    case {'spm'}    
        s = struct('face',[], 'vert',[]);
        if isfield(this,'vertices')
            s.vert = double(subsref(this, substruct('.', 'vertices')));
        end
        if isfield(this,'faces')
            s.face = uint16(subsref(this, substruct('.', 'faces')));
        end
        
    otherwise
        error('Unknown target ''%s''.', target);
end
