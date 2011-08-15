function [D] = spm_eeg_review_uis(D,objects)
% GUI of the M/EEG Review facility
%__________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% Jean Daunizeau
% $Id: spm_eeg_review_uis.m 4432 2011-08-15 12:43:44Z christophe $

% POS = get(D.PSD.handles.hfig,'position');

switch objects.type


    case 'buttons'

        load spm_eeg_review_buttons.mat

        if ismember(1,objects.list) % save/prep button
            D.PSD.handles.BUTTONS.pop1 = uicontrol(D.PSD.handles.hfig,...
                'units','normalized',...
                'Position',[0.89 0.975 0.1 0.02],...
                'style','pushbutton',...
                'string','SAVE',...
                'callback','spm_eeg_review_callbacks(''file'',''save'')',...
                'tooltipstring','Overwrite SPM data file',...
                'BusyAction','cancel',...
                'Interruptible','off');
            D.PSD.handles.BUTTONS.prep = uicontrol(D.PSD.handles.hfig,...
                'units','normalized',...
                'Position',[0.7 0.975 0.18 0.02],...
                'style','pushbutton','string','Prepare SPM file',...
                'callback','spm_eeg_review_callbacks(''edit'',''prep'')',...
                'tooltipstring','Prepare SPM data file (use SPM input figure)',...
                'enable','on',...
                'BusyAction','cancel',...
                'Interruptible','off');
        end

        if ismember(2,objects.list) % temporal sliders buttons
            D.PSD.handles.BUTTONS.goMinusOne = uicontrol(D.PSD.handles.hfig,...
                'style','pushbutton',...
                'cdata',repmat(Y1,[1,1,3]),...
                'units','normalized',...
                'Position',[0.06 0.02 0.02 0.02],...
                'callback',...
                'spm_eeg_review_callbacks(''visu'',''goOne'',-1)',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tooltipstring','Go one page backward',...
                'tag','plotEEG');
            D.PSD.handles.BUTTONS.goPlusOne = uicontrol(D.PSD.handles.hfig,...
                'style','pushbutton',...
                'cdata',repmat(Y2,[1,1,3]),...
                'units','normalized',...
                'Position',[0.942 0.02 0.02 0.02],...
                'callback','spm_eeg_review_callbacks(''visu'',''goOne'',+1)',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tooltipstring','Go one page forward',...
                'tag','plotEEG');
        end

        if ismember(3,objects.list) % width of time window
            D.PSD.handles.BUTTONS.vb3 = uicontrol(D.PSD.handles.hfig,...
                'units','normalized',...
                'Position',[0.02 0.925 0.05 0.04],...
                'cdata',Y5,...
                'Callback','spm_eeg_review_callbacks(''visu'',''time_w'',2)',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tooltipstring','Increase width of the plotted time window',...
                'tag','plotEEG');
            D.PSD.handles.BUTTONS.vb4 = uicontrol(D.PSD.handles.hfig,...
                'units','normalized',...
                'Position',[0.08 0.925 0.05 0.04],...
                'cdata',Y6,...
                'Callback','spm_eeg_review_callbacks(''visu'',''time_w'',0.5)',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tooltipstring','Decrease width of the plotted time window',...
                'tag','plotEEG');
            if isequal(D.PSD.VIZU.xlim,[1 D.nsamples])
                set(D.PSD.handles.BUTTONS.vb3,'enable','off');
            end
        end

        if ismember(4,objects.list) % Global scaling buttons
            D.PSD.handles.BUTTONS.vb1 = uicontrol(D.PSD.handles.hfig,...
                'units','normalized',...
                'Position',[0.14 0.925 0.05 0.04],...
                'cdata',Y3,...
                'Callback','spm_eeg_review_callbacks(''visu'',''iten_sc'',2)',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tooltipstring','Increase contrast (intensity rescaling)',...
                'tag','plotEEG');
            D.PSD.handles.BUTTONS.vb2 = uicontrol(D.PSD.handles.hfig,...
                'units','normalized',...
                'Position',[0.2 0.925 0.05 0.04],...
                'cdata',Y4,...
                'Callback','spm_eeg_review_callbacks(''visu'',''iten_sc'',0.5)',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tooltipstring','Decrease contrast (intensity rescaling)',...
                'tag','plotEEG');
        end

        if ismember(5,objects.list) % zoom button
            D.PSD.handles.BUTTONS.vb5 = uicontrol(D.PSD.handles.hfig,...
                'style','togglebutton',...
                'units','normalized',...
                'Position',[0.26 0.925 0.05 0.04],...
                'cdata',Y7,...
                'callback','spm_eeg_review_callbacks(''visu'',''zoom'',1)',...
                'value',0,...
                'min',0,'max',1,...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tooltipstring','Zoom in (mouse box)',...
                'tag','plotEEG');
            try % only with MATLAB 7.1 and later versions
                D.PSD.handles.zoomh = zoom(D.PSD.handles.hfig);
            catch 
                D.PSD.handles.zoomh = [];
            end
        end


        if ismember(6,objects.list) % scalp interpolation button
            D.PSD.handles.BUTTONS.vb1 = uicontrol(D.PSD.handles.hfig,...
                'units','normalized',...
                'Position',[0.34 0.925 0.05 0.04],...
                'cdata',Y8,...
                'Callback','spm_eeg_review_callbacks(''visu'',''scalp_interp'',1)',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tooltipstring','scalp interpolation (image scalp data)',...
                'tag','plotEEG');
        end


        if ismember(7,objects.list) % event selection button
            trN = D.PSD.trials.current;
            D.PSD.handles.BUTTONS.list1 = uicontrol(D.PSD.handles.hfig,...
                'style','listbox',...
                'string',D.PSD.trials.TrLabels,...
                'callback','spm_eeg_review_callbacks(''select'',''switch'')',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'min',1,'max',length(D.PSD.trials.TrLabels)+1,...
                'value',trN,...
                'units','normalized',...
                'tag','plotEEG');
            if objects.options.multSelect == 1  % 'scalp' display
                set(D.PSD.handles.BUTTONS.list1,...
                    'Position',[0.55 0.834 0.35 0.13]);
            else                                % 'standard' display
                trN = trN(1);
                set(D.PSD.handles.BUTTONS.list1,...
                    'Position',[0.55 0.922 0.35 0.043]);
            end
        end

        if ismember(8,objects.list) % temporal sliders for source
            pst = objects.options.pst;
            nt = length(pst);
            t0 = objects.options.gridTime;
            D.PSD.handles.BUTTONS.slider_step = uicontrol(D.PSD.handles.hfig,...
                'style','slider',...
                'units','normalized',...
                'Position',[0.12 0.6 0.44 0.018],...
                'min',pst(1),'max',pst(end),'value',t0,...
                'sliderstep',[1/(nt-1) 2/(nt-1)],...
                'callback','spm_eeg_review_callbacks(''visu'',''slider_t'',0)',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tooltipstring','Scroll data',...
                'tag','plotEEG');
        end

        if ismember(9,objects.list)  % add/goto event buttons
            D.PSD.handles.BUTTONS.sb1 = uicontrol(D.PSD.handles.hfig,...
                'units','normalized',...
                'Position',[0.56 0.925 0.05 0.04],...
                'cdata',Y9,...
                'callback','spm_eeg_review_callbacks(''select'',''add'')',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tooltipstring','Add event to current selection (1 mouse click)',...
                'tag','plotEEG');
            % Selection buttons
            Nevents = length(events(D));
            if Nevents > 0
                enab = 'on';
            else
                enab = 'off';
            end
            D.PSD.handles.BUTTONS.sb2 = uicontrol(D.PSD.handles.hfig,...
                'units','normalized',...
                'Position',[0.42 0.925 0.05 0.04],...
                'cdata',Y10,...
                'callback','spm_eeg_review_callbacks(''select'',''goto'',0)',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tooltipstring','Go to closest selected event (forward)','enable',enab,...
                'tag','plotEEG');
            D.PSD.handles.BUTTONS.sb3 = uicontrol(D.PSD.handles.hfig,...
                'units','normalized','Position',[0.48 0.925 0.05 0.04],...
                'cdata',Y11,'callback','spm_eeg_review_callbacks(''select'',''goto'',1)',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tooltipstring','Go to closest selected event (backward)','enable',enab,...
                'tag','plotEEG');
        end

        if ismember(10,objects.list)  % source buttons positions...
            set(D.PSD.handles.BUTTONS.transp,...
                'units','normalized',...
                'position',[0.1 0.65 0.025 0.2],...
                'visible','on')
            set(D.PSD.handles.BUTTONS.ct1,...
                'units','normalized',...
                'position',[0.47 0.65 0.025 0.2],...
                'visible','on')
            set(D.PSD.handles.BUTTONS.ct2,...
                'units','normalized',...
                'position',[0.4975 0.65 0.025 0.2],...
                'visible','on')
            set(D.PSD.handles.colorbar,...
                'units','normalized',...
                'position',[0.53 0.65 0.025 0.2],...
                'visible','on')
        end
        
        if ismember(11,objects.list)  % display switch (standard/scalp)...
            switch  D.PSD.VIZU.type
                case 1
                    val = 1;
                case 2
                    val = 0;
            end
            D.PSD.handles.BUTTONS.displaySwitch1 = uicontrol(D.PSD.handles.hfig,...
                'units','normalized',...
                'Position',[0.42 0.945 0.1 0.02],...
                'style','radio',...
                'string','standard',...
                'callback','spm_eeg_review_callbacks(''visu'',''switch'')',...
                'tooltipstring','Change display type to ''standard''',...
                'userdata',1,...
                'value',val,...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tag','plotEEG');
            D.PSD.handles.BUTTONS.displaySwitch2 = uicontrol(D.PSD.handles.hfig,...
                'units','normalized',...
                'Position',[0.42 0.925 0.1 0.02],...
                'style','radio',...
                'string','scalp',...
                'callback','spm_eeg_review_callbacks(''visu'',''switch'')',...
                'tooltipstring','Change display type to ''scalp''',...
                'userdata',2,...
                'value',~val,...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tag','plotEEG');        
        end

        if ismember(12,objects.list)  % UPDATE button for data info modifs
            D.PSD.handles.BUTTONS.OKinfo = uicontrol(D.PSD.handles.hfig,...
                'units','normalized',...
                'Position',[0.1 0.76 0.1 0.02],...
                'style','pushbutton',...
                'string','update',...
                'callback','spm_eeg_review_callbacks(''get'',''uitable'')',...
                'tooltipstring','Upload changes to SPM meeg object',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tag','plotEEG');
        end
        
        if ismember(13,objects.list)  % switch 'bad' event status
            trN = D.PSD.trials.current;
            status = any(intersect(trN,find(reject(D))));
            if status
                str = 'declare as not bad';
                val = 0;
            else
                str = 'declare as bad';
                val = 1;
            end
            ud.img = {Y12,Y13};
            D.PSD.handles.BUTTONS.badEvent = uicontrol(D.PSD.handles.hfig,...
                'units','normalized',...
                'Position',[0.91 0.925 0.05 0.04],...
                'style','pushbutton',...
                'callback','spm_eeg_review_callbacks(''select'',''bad'')',...
                'tooltipstring',str,...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tag','plotEEG',...
                'cdata',ud.img{val+1},...
                'userdata',ud);
        end
        
        if ismember(14,objects.list)  % show sensor positions
            D.PSD.handles.BUTTONS.showSensors = uicontrol(D.PSD.handles.hfig,...
                'units','normalized',...
                'Position',[0.4 0.76 0.25 0.02],...
                'style','pushbutton',...
                'string','show sensors 3D positions',...
                'callback','spm_eeg_review_callbacks(''visu'',''sensorPos'')',...
                'tooltipstring','Show sensors 3D positions',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tag','plotEEG');
        end
        
        if ismember(15,objects.list)  % save history as MATLAB script
            D.PSD.handles.BUTTONS.saveHistory = uicontrol(D.PSD.handles.hfig,...
                'units','normalized',...
                'Position',[0.1 0.76 0.2 0.02],...
                'style','pushbutton',...
                'string','Save as script',...
                'callback','spm_eeg_review_callbacks(''file'',''saveHistory'')',...
                'tooltipstring','Save history as MATLAB script',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tag','plotEEG');
        end

    case 'axes'

        switch objects.what


            case 'standard'

                % Axes of 'standard' display are defined by
                % spm_DisplayTimeSeries.m

            case 'scalp'

                % I = channels for which to create axes (eeg/meg/other)
                I = objects.options.channelPlot;
                Npos = length(I);
                if ~isempty(I)
                    trN = D.PSD.trials.current(1);
                    p = [];
                    try
                        p = coor2D(meeg(D), I, [], 0.03);
                    end
                    if ~isequal(size(p,2),Npos)
                    % create dummy 2D channel positions
                        ss = floor(sqrt(length(I)));
                        x = 0;
                        y = 0;
                        for i=1:length(I)
                            x = x+1;
                            if x > ss
                                y = y-1;
                                x = 1;
                            end
                            p(1,i) = x;
                            p(2,i) = y;
                        end
                    end
                    if strcmp(transformtype(D),'time')
                        y = D(I,:,trN);
                    else
                        y = D(I,:,:,trN);
                    end
                    miY = min(y(:));
                    maY = max(y(:));
                    
                    if miY == 0 && maY == 0
                        miY = -eps;
                        maY = eps;
                    else
                        miY = miY - miY.*1e-3;
                        maY = maY + maY.*1e-3;
                    end
                    % position of plotting area for eeg data in graphics figure
                    if size(p,2) <= 16  % for aesthetics purposes
                        Pos = [0.023 0.05 0.95 0.52];
                    else
                        Pos = [0.023 0.05 0.95 0.72];
                    end
                    % Compute width of display boxes
                    Rxy = 1.5; % ratio of x- to y-axis lengths
                    if Npos > 1
                        % more than 1 channel for display
                        d = zeros(Npos,Npos);
                        alpha = zeros(Npos,Npos);
                        for i = 1:Npos
                            for j = 1:Npos
                                % distance between channels
                                d(i,j) = sqrt(sum((p(:,j)-p(:,i)).^2));
                                % their angle
                                alpha(i,j) = acos((p(1,j)-p(1,i))/(d(i,j)+eps));
                            end
                        end
                        d = d/2;
                        alpha(alpha > pi/2) = pi-alpha(alpha > pi/2);
                        Talpha = asin(1/(sqrt(1+Rxy^2)));
                        for i = 1:Npos
                            for j = 1:Npos
                                if alpha(i,j) <= Talpha
                                    x(i,j) = d(i,j)*cos(alpha(i,j));
                                else
                                    x(i,j) = Rxy*d(i,j)*cos(pi/2-alpha(i,j));
                                end
                            end
                        end
                        % half length of axes in x-direction
                        Lxrec = min(x(find(x~=0)));
                    else
                        % only one channel
                        Lxrec = 1;
                    end
                    % coordinates of lower left corner of drawing boxes
                    p(1, :) = p(1, :) - Lxrec;
                    p(2, :) = p(2, :) - Lxrec/Rxy;
                    % envelope of coordinates
                    e = [min(p(1,:)) max(p(1,:))+2*Lxrec min(p(2,:)) max(p(2,:))+2*Lxrec/Rxy];
                    % shift coordinates to zero
                    p(1,:) = p(1,:) - mean(e(1:2));
                    p(2,:) = p(2,:) - mean(e(3:4));
                    % scale such that envelope goes from -0.5 to 0.5
                    Sf = 0.5/max(max(abs(p(1,:))), (max(abs(p(2,:)))));
                    p = Sf*p;
                    Lxrec = Sf*Lxrec;
                    % and back to centre
                    p = p+0.5;
                    % translate and scale to fit into drawing area of figure
                    p(1,:) = Pos(3)*p(1,:)+Pos(1);
                    p(2,:) = Pos(4)*p(2,:)+Pos(2);
                    % cell vector for axes handles of single channel plots
                    handles.axes = zeros(1, Npos);
                    % create axes
                    for i = 1:Npos
                        % use frames behind the axes because of weird bug when hitting axes...
                        D.PSD.handles.fra(i) = uipanel('Parent', D.PSD.handles.hfig,...
                            'units','normalized',...
                            'Position',[p(1,i) p(2,i) 2*Lxrec*Pos(3) 2*Lxrec/Rxy*Pos(4)],...
                            'userdata',i,...
                            'tag','plotEEG');
                        D.PSD.handles.axes(i) = axes('Parent', D.PSD.handles.hfig,...
                            'units','normalized',...
                            'Position',[p(1,i) p(2,i) 2*Lxrec*Pos(3) 2*Lxrec/Rxy*Pos(4)],...
                            'NextPlot','replacechildren',...
                            'YLim',[miY maY],...
                            'YLimMode','manual',...
                            'XLim',[1 D.nsamples],...
                            'XLimMode','manual',...
                            'XTick',[],...
                            'YTick',[],...
                            'Box','off',...
                            'userdata',i,...
                            'hittest','off',...
                            'ALimMode','manual',...
                            'tag','plotEEG');
                        if ~strcmp(transformtype(D),'time')
                            if length(frequencies(D)) == 1
                                
                            else
                                set(D.PSD.handles.axes(i),'ylim',...
                                    [1 length(frequencies(D))]);
                            end
                        end

                    end
                    % create global scale axes
                    if strcmp(transformtype(D),'time') % only for time data!
                        D.PSD.handles.scale = axes('Parent', D.PSD.handles.hfig,...
                            'units','normalized',...
                            'color',0.95*[1 1 1],...
                            'xtick',1,...
                            'xticklabel',[num2str(D.nsamples.*1e3./D.fsample),' ms'],... %CP
                            'ytick',1,...
                            'userdata',0,...
                            'tag','plotEEG',...
                            'hittest','off',...
                            'position',...
                            [0.15 max(p(2,:))+2*Lxrec/Rxy*Pos(4)+0.03...
                            2*Lxrec*Pos(3) 2*Lxrec/Rxy*Pos(4)]);
                    end
                end

                
            case 'source'
                % create model comparison axes
                if objects.options.Ninv>1
                    D.PSD.handles.BMCpanel = uipanel('Parent', D.PSD.handles.hfig,...
                        'units','normalized',...
                        'position',[0.42 0.05 0.5 0.25],...
                        'bordertype','beveledin',...
                        'BackgroundColor',0.95*[1 1 1],...
                        'visible','off',...
                        'tag','plotEEG');
                    D.PSD.handles.BMCplot = axes('Parent', D.PSD.handles.hfig,...
                        'units','normalized',...
                        'position',[0.5 0.1 0.4 0.15],...
                        'nextplot','add',...
                        'box','on',...
                        'ygrid','on',...
                        'visible','off',...
                        'tag','plotEEG',...
                        'hittest','off');
                    set(get(D.PSD.handles.BMCplot,'xlabel'),...
                        'string','Inversion models');
                    set(get(D.PSD.handles.BMCplot,'ylabel'),...
                        'string','Relative (to min) model free energies')
                    set(get(D.PSD.handles.BMCplot,'title'),...
                        'string','Bayesian model comparison',...
                        'FontWeight','bold')
                end
                miJ = objects.options.miJ;
                maJ = objects.options.maJ;
                % create time courses displaying axes
                xlim = [min(objects.options.pst),max(objects.options.pst)];
                D.PSD.handles.axes2 = axes('Parent', D.PSD.handles.hfig,...
                    'units','normalized',...
                    'position',[0.14 0.35 0.4 0.2],...
                    'parent',D.PSD.handles.hfig,...
                    'tag','plotEEG',...
                    'box','on',...
                    'xlim',xlim,...
                    'ylim',[miJ maJ],...
                    'nextplot','add',...
                    'visible','off',...
                    'hittest','off');
                grid(D.PSD.handles.axes2,'on')
                xlabel(D.PSD.handles.axes2,'peri-stimulus time (ms)')
                ylabel(D.PSD.handles.axes2,'source activity (bounds)')
%                 % create axes for scalp plots
%                 D.PSD.handles.axes3 = axes('position',[0.64 0.35 0.4 0.2],...
%                     'parent',D.PSD.handles.hfig,'tag','plotEEG',...
%                     'box','on','hittest','off');
%                 D.PSD.handles.axes4 = axes('position',[0.64 0.65 0.4 0.2],...
%                     'parent',D.PSD.handles.hfig,'tag','plotEEG',...
%                     'box','on','hittest','off');
                % create textured mesh displaying axes
                D.PSD.handles.axes = axes('Parent', D.PSD.handles.hfig,...
                    'units','normalized',...
                    'position',[0.1 0.6 0.4 0.3],...
                    'parent',D.PSD.handles.hfig,...
                    'tag','plotEEG',...
                    'box','on',...
                    'CLimMode','Manual',...
                    'CLim',[miJ maJ],...
                    'visible','off',...
                    'hittest','off');
        end
        
    case 'text'
        
        switch objects.what
            
            case 'data'
                
                [out] = spm_eeg_review_callbacks('get','dataInfo');
                str = out;
                [FS,sf] = spm('FontSize',8);
                D.PSD.handles.infoText = uicontrol('Parent',D.PSD.handles.hfig,...
                    'style','text',...
                    'string',str,...
                    'units','normalized',...
                    'position',[0.05 0.85 0.8 0.10],...
                    'HorizontalAlignment','left',...
                    'Fontsize',FS,...
                    'BackgroundColor',0.95*[1 1 1],...
                    'tag','plotEEG');
                
            case 'source'
                
                % Text uicontrols for inverse method info
                isInv = D.PSD.source.VIZU.isInv;
                invN = isInv(D.PSD.source.VIZU.current);
                [out] = spm_eeg_review_callbacks('get','commentInv',invN);
                str = out;
                [FS,sf] = spm('FontSize',8);
                D.PSD.handles.infoText = uicontrol('Parent',D.PSD.handles.hfig,...
                    'style','text',...
                    'string',str,...
                    'units','normalized',...
                    'position',[0.09 0.08 0.3 0.21],...
                    'HorizontalAlignment','left',...
                    'Fontsize',FS,...
                    'BackgroundColor',0.95*[1 1 1],...
                    'tag','plotEEG');
                
        end
        
end
