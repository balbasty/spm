function [handles] = spm_uitab(hparent,labels,callbacks,tag,active)
% function [handles] = spm_uitab(hfig,labels,callbacks)
% This functiuon creates tabs in the SPM graphics window.
% These tabs may be associated with different sets of axes and uicontrol,
% through the use of callback functions linked to the tabs.
% IN:
%   - hparent: the handle of the parent of the tabs (can be the SPM graphics
%   windows, or the handle of the uipanel of a former spm_uitab...)
%   - labels: a cell array of string containing the labels of the tabs
%   - callbacks: a cell array of strings which will be evaluated using the
%   'eval' function when clicking on a tab.
%   - tag: a string which is the tags associated with the tabs (useful for
%   finding them in a window...)
%   - active: the index of the active tab when creating the uitabs (default
%   = 1).
% OUT:
%   - handles: a structure of handles for the differents tab objects.
%__________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% Jean Daunizeau
% $Id: spm_uitab.m 1928 2008-07-18 10:17:05Z jean $

Ntabs = length(labels);

if ~exist('callbacks','var') || isempty(callbacks)
    for i=1:Ntabs
        callbacks{i} = [];
    end
end
if  ~exist('tag','var') || isempty(tag)
    tag = '';
end
if  ~exist('active','var') || isempty(active)
    active = 1;
end

if ~isequal(get(hparent,'type'),'figure')
    set(hparent,'units','normalized')
    POS = get(hparent,'position');
    pos1 = [POS(1)+0.02,POS(2)+0.01,POS(3)-0.04,POS(4)-0.06];
    dx = 0.1*(POS(3)-0.04)./0.98;
    dx2 = [0.04,0.93]*(POS(3)-0.04)./0.98;
else
    pos1 = [0.01 0.005 0.98 0.965];
    dx = 0.1;
    dx2 = [0.04,0.93];
end


handles.hp = uipanel('position',pos1,...
    'BorderType','beveledout',...
    'BackgroundColor',0.95*[1 1 1],...
    'parent',hparent,...
    'tag',tag);
set(handles.hp,'units','normalized');

xl = pos1(1);
yu = pos1(2) +pos1(4);
ddx = 0.0025;
ddy = 0.005;
dy = 0.025;

if Ntabs > 9
    handles.hs(1) = uicontrol('style','pushbutton',...
        'units','normalized','position',[xl yu dx2(1) dy],...
        'SelectionHighlight','off',...
        'callback',@doScroll,...
        'value',0,'min',0,'max',Ntabs-9,...
        'string','<',...
        'parent',hparent,...'enable','off',...
        'tag',tag,...
        'BusyAction','cancel',...
        'Interruptible','off');

    handles.hs(2) = uicontrol('style','pushbutton',...
        'units','normalized','position',[xl+dx2(2) yu 0.05 dy],...
        'SelectionHighlight','off',...
        'callback',@doScroll,...
        'value',1,'min',1,'max',Ntabs-9,...
        'string','>',...
        'parent',hparent,...
        'tag',tag,...
        'BusyAction','cancel',...
        'Interruptible','off');
    set(handles.hs,'units','normalized')
    xl = xl + dx2(1);
end

for i =1:min([Ntabs,9])
    pos = [xl+dx*(i-1) yu dx dy];
    handles.htab(i) = uicontrol('style','pushbutton',...
        'units','normalized','position',pos,...
        'SelectionHighlight','off',...
        'string',labels{i},...
        'BackgroundColor',0.95*[1 1 1],...
        'parent',hparent,...
        'tag',tag);
    set(handles.htab(i),'units','normalized')
    pos = [xl+dx*(i-1)+ddx yu-ddy dx-2*ddx 2*ddy];
    handles.hh(i) = uicontrol('style','text',...
        'units','normalized','position',pos,...
        'BackgroundColor',0.95*[1 1 1],...
        'parent',hparent,...
        'tag',tag);
    set(handles.hh(i),'units','normalized')
end
set(handles.hh(active),'visible','on')
others = setdiff(1:min([Ntabs,9]),active);
set(handles.htab(active),...
    'FontWeight','bold');
set(handles.hh(others),'visible','off');
set(handles.htab(others),...
    'ForegroundColor',0.25*[1 1 1]);
ud.handles = handles;
ud.Ntabs = Ntabs;
for i =1:min([Ntabs,9])
    ud.ind = i;
    ud.callback = callbacks{i};
    set(handles.htab(i),'callback',@doChoose,'userdata',ud,...
        'BusyAction','cancel',...
        'Interruptible','off');
    if i > 9
        set(handles.htab(i),'visible','off');
    end
end

if Ntabs > 9
    UD.in = [1:9];
    UD.Ntabs = Ntabs;
    UD.h = handles;
    UD.active = active;
    UD.who = -1;
    UD.callbacks = callbacks;
    UD.labels = labels;
    set(handles.hs(1),'userdata',UD,'enable','off');
    UD.who = 1;
    set(handles.hs(2),'userdata',UD);
end



function doChoose(o1,o2)
ud = get(gco,'userdata');
% Do nothing if called tab is curret (active) tab
if ~strcmp(get(ud.handles.htab(ud.ind),'FontWeight'),'bold')
    spm('pointer','watch');
    set(ud.handles.hh(ud.ind),'visible','on');
    set(ud.handles.htab(ud.ind),...
        'ForegroundColor',0*[1 1 1],...
        'FontWeight','bold');
    others = setdiff(1:length(ud.handles.hh),ud.ind);
    set(ud.handles.hh(others),'visible','off');
    set(ud.handles.htab(others),...
        'ForegroundColor',0.25*[1 1 1],...
        'FontWeight','normal');
    if ud.Ntabs >9
        UD = get(ud.handles.hs(1),'userdata');
        UD.active = UD.in(ud.ind);
        UD.who = -1;
        set(ud.handles.hs(1),'userdata',UD);
        UD.who = 1;
        set(ud.handles.hs(2),'userdata',UD);
    end
    drawnow
    if ~isempty(ud.callback)
        eval(ud.callback);
    end
    drawnow
    spm('pointer','arrow');
end

function doScroll(o1,o2)
ud = get(gco,'userdata');
% active = ud.in(ud.active);
ud.in = ud.in + ud.who;
if min(ud.in) ==1
    set(ud.h.hs(1),'enable','off');
    set(ud.h.hs(2),'enable','on');
elseif max(ud.in) ==ud.Ntabs
    set(ud.h.hs(1),'enable','on');
    set(ud.h.hs(2),'enable','off');
else
    set(ud.h.hs,'enable','on');
end
UD.handles = ud.h;
UD.Ntabs = ud.Ntabs;
for i = 1:length(ud.in)
    UD.ind = i;
    UD.callback = ud.callbacks{ud.in(i)};
    set(ud.h.htab(i),'userdata',UD,...
        'string',ud.labels{ud.in(i)});
    if ismember(ud.active,ud.in)
        ind = find(ud.in==ud.active);
        set(ud.h.hh(ind),'visible','on');
        set(ud.h.htab(ind),...
            'ForegroundColor',0*[1 1 1],...
            'FontWeight','bold');
        others = setdiff(1:9,ind);
        set(ud.h.hh(others),'visible','off');
        set(ud.h.htab(others),...
            'ForegroundColor',0.25*[1 1 1],...
            'FontWeight','normal');
    else
        others = 1:9;
        set(ud.h.hh(others),'visible','off');
        set(ud.h.htab(others),...
            'ForegroundColor',0.25*[1 1 1],...
            'FontWeight','normal');
    end
end

ud.who = -1;
set(ud.h.hs(1),'userdata',ud)
ud.who = 1;
set(ud.h.hs(2),'userdata',ud)



