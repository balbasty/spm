function [D] = spm_eeg_review_uis(D,objects)
%__________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% Jean Daunizeau

dbstop if error

POS = get(D.PSD.handles.hfig,'position');

switch objects.type


    case 'buttons'

        load spm_eeg_review_buttons.mat

        if ismember(1,objects.list) % save/prep button
            D.PSD.handles.BUTTONS.pop1 = uicontrol(D.PSD.handles.hfig,'Position',...
                [0.89 0.975 0.1 0.02].*repmat(POS(3:4),1,2),...
                'style','pushbutton','string','SAVE',...
                'callback','spm_eeg_review_callbacks(''file'',''save'')',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tag','plotEEG');
            set(D.PSD.handles.BUTTONS.pop1,'units','normalized')
            D.PSD.handles.BUTTONS.prep = uicontrol(D.PSD.handles.hfig,'Position',...
                [0.7 0.975 0.18 0.02].*repmat(POS(3:4),1,2),...
                'style','pushbutton','string','Prepare SPM file',...
                'callback','spm_eeg_review_callbacks(''edit'',''prep'')',...
                'tooltipstring','!Prepare SPM data file (use SPM input figure)!',...
                'enable','on',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tag','plotEEG');
            set(D.PSD.handles.BUTTONS.prep,'units','normalized')
        end

        if ismember(2,objects.list) % temporal sliders buttons
            xlim = D.PSD.VIZU.xlim;
            length_window = xlim(2)-xlim(1);
            ratio = length_window/200;
            D.PSD.handles.BUTTONS.slider_step = uicontrol(D.PSD.handles.hfig,'style','slider',...
                'Position',[0.1 0.02 0.665 0.02].*repmat(POS(3:4),1,2),...
                'min',1,'max',D.Nsamples,'value',mean(xlim),...
                'sliderstep',[ratio*10/(D.Nsamples-1) ratio*20/(D.Nsamples-1)],...
                'callback','spm_eeg_review_callbacks(''visu'',''slider_t'',0)',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tooltipstring','Scroll data',...
                'tag','plotEEG');
            set(D.PSD.handles.BUTTONS.slider_step,'units','normalized')
            D.PSD.handles.BUTTONS.goPlusOne = uicontrol(D.PSD.handles.hfig,'style',...
                'pushbutton','cdata',repmat(Y1,[1,1,3]),...
                'Position',[0.075 0.02 0.025 0.02].*repmat(POS(3:4),1,2),'callback',...
                'spm_eeg_review_callbacks(''visu'',''goOne'',0)',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tooltipstring','Go one page backward',...
                'tag','plotEEG');
            set(D.PSD.handles.BUTTONS.goPlusOne,'units','normalized')
            D.PSD.handles.BUTTONS.goMinusOne = uicontrol(D.PSD.handles.hfig,'style',...
                'pushbutton','cdata',repmat(Y2,[1,1,3]),...
                'Position',[0.765 0.02 0.025 0.02].*repmat(POS(3:4),1,2),'callback',...
                'spm_eeg_review_callbacks(''visu'',''goOne'',1)',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tooltipstring','Go one page forward',...
                'tag','plotEEG');
            set(D.PSD.handles.BUTTONS.goMinusOne,'units','normalized')
            if isequal(xlim,[1 D.Nsamples])
                set(D.PSD.handles.BUTTONS.slider_step,'visible','off');
                set(D.PSD.handles.BUTTONS.goPlusOne,'visible','off');
                set(D.PSD.handles.BUTTONS.goMinusOne,'visible','off');
            end
            %     D.PSD.handles.BUTTONS.focus_temp = uicontrol(D.PSD.handles.hfig,'style','edit',...
            %         'enable','on','callback','spm_eeg_review_callbacks(''visu'',''focus_t'',0)',...
            %         'BusyAction','cancel',...
            %         'Interruptible','off',...
            %         'Position',[0.9 0.02 0.05 0.02].*repmat(POS(3:4),1,2),'string',round(mean(xlim)),...
            %         'tag','plotEEG');
            %     set(D.PSD.handles.BUTTONS.focus_temp,'units','normalized')
        end

        if ismember(3,objects.list) % width of time window
            D.PSD.handles.BUTTONS.vb3 = uicontrol(D.PSD.handles.hfig,'Position',...
                [0.02 0.925 0.05 0.04].*repmat(POS(3:4),1,2),'cdata',Y5,...
                'Callback','spm_eeg_review_callbacks(''visu'',''time_w'',2)',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tooltipstring','Increase width of the plotted time window',...
                'tag','plotEEG');
            set(D.PSD.handles.BUTTONS.vb3,'units','normalized');
            D.PSD.handles.BUTTONS.vb4 = uicontrol(D.PSD.handles.hfig,'Position',...
                [0.08 0.925 0.05 0.04].*repmat(POS(3:4),1,2),'cdata',Y6,...
                'Callback','spm_eeg_review_callbacks(''visu'',''time_w'',0.5)',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tooltipstring','Decrease width of the plotted time window',...
                'tag','plotEEG');
            set(D.PSD.handles.BUTTONS.vb4,'units','normalized');
            if isequal(D.PSD.VIZU.xlim,[1 D.Nsamples])
                set(D.PSD.handles.BUTTONS.vb3,'enable','off');
            end
        end

        if ismember(4,objects.list) % Global scaling buttons
            D.PSD.handles.BUTTONS.vb1 = uicontrol(D.PSD.handles.hfig,'Position',...
                [0.14 0.925 0.05 0.04].*repmat(POS(3:4),1,2),'cdata',Y3,...
                'Callback','spm_eeg_review_callbacks(''visu'',''iten_sc'',2)',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tooltipstring','Increase contrast (intensity rescaling)',...
                'tag','plotEEG');
            set(D.PSD.handles.BUTTONS.vb1,'units','normalized');
            D.PSD.handles.BUTTONS.vb2 = uicontrol(D.PSD.handles.hfig,'Position',...
                [0.2 0.925 0.05 0.04].*repmat(POS(3:4),1,2),'cdata',Y4,...
                'Callback','spm_eeg_review_callbacks(''visu'',''iten_sc'',0.5)',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tooltipstring','Decrease contrast (intensity rescaling)',...
                'tag','plotEEG');
            set(D.PSD.handles.BUTTONS.vb2,'units','normalized');
        end

        if ismember(5,objects.list) % zoom button
            D.PSD.handles.BUTTONS.vb5 = uicontrol(D.PSD.handles.hfig,'Position',...
                [0.26 0.925 0.05 0.04].*repmat(POS(3:4),1,2),'cdata',Y7,...
                'callback','spm_eeg_review_callbacks(''visu'',''zoom'',1)',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tooltipstring','Zoom in (mouse box)',...
                'tag','plotEEG');
            set(D.PSD.handles.BUTTONS.vb5,'units','normalized');
        end


        if ismember(6,objects.list) % scalp interpolation button
            D.PSD.handles.BUTTONS.vb1 = uicontrol(D.PSD.handles.hfig,'Position',...
                [0.34 0.925 0.05 0.04].*repmat(POS(3:4),1,2),'cdata',Y8,...
                'Callback','spm_eeg_review_callbacks(''visu'',''scalp_interp'',1)',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tooltipstring','scalp interpolation (image scalp data)',...
                'tag','plotEEG');
            set(D.PSD.handles.BUTTONS.vb1,'units','normalized');
        end


        if ismember(7,objects.list) % event selection button
            trN = D.PSD.trials.current;
            if objects.options.multSelect == 1
                D.PSD.handles.BUTTONS.pop1 = uicontrol(D.PSD.handles.hfig,'Position',...
                    [0.55 0.834 0.25 0.13].*repmat(POS(3:4),1,2),...
                    'style','listbox','min',1,'max',length(D.PSD.trials.TrLabels)+1,...
                    'string',D.PSD.trials.TrLabels,...
                    'value',trN,...
                    'callback','spm_eeg_review_callbacks(''select'',''switch'')',...
                    'BusyAction','cancel',...
                    'Interruptible','off',...
                    'tag','plotEEG');
                set(D.PSD.handles.BUTTONS.pop1,'units','normalized')
            else
                trN = trN(1);
                D.PSD.handles.BUTTONS.pop1 = uicontrol(D.PSD.handles.hfig,'Position',...
                    [0.55 0.825 0.25 0.13].*repmat(POS(3:4),1,2),...
                    'style','popupmenu','min',1,'max',length(D.PSD.trials.TrLabels),...
                    'string',D.PSD.trials.TrLabels,...
                    'value',trN,...
                    'callback','spm_eeg_review_callbacks(''select'',''switch'')',...
                    'BusyAction','cancel',...
                    'Interruptible','off',...
                    'tag','plotEEG');
                set(D.PSD.handles.BUTTONS.pop1,'units','normalized')
            end
        end

        if ismember(8,objects.list) % temporal sliders for source
            pst = objects.options.pst;
            nt = length(pst);
            D.PSD.handles.BUTTONS.slider_step = uicontrol(D.PSD.handles.hfig,'style','slider',...
                'Position',[0.2 0.58 0.4 0.018].*repmat(POS(3:4),1,2),...
                'min',pst(1),'max',pst(end),'value',pst(1),...
                'sliderstep',[1/(nt-1) 2/(nt-1)],...
                'callback','spm_eeg_review_callbacks(''visu'',''slider_t'',0)',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tooltipstring','Scroll data',...
                'tag','plotEEG');
            set(D.PSD.handles.BUTTONS.slider_step,'units','normalized')
            D.PSD.handles.BUTTONS.focus_temp = uicontrol(D.PSD.handles.hfig,'style','edit',...
                'enable','on','callback','spm_eeg_review_callbacks(''visu'',''focus_t'',0)',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'Position',[0.63 0.58 0.15 0.02].*repmat(POS(3:4),1,2),'string',1,...
                'tag','plotEEG');
            set(D.PSD.handles.BUTTONS.focus_temp,'units','normalized')
        end

        if ismember(9,objects.list)  % add/goto event buttons
            D.PSD.handles.BUTTONS.sb1 = uicontrol(D.PSD.handles.hfig,'Position',...
                [0.56 0.925 0.05 0.04].*repmat(POS(3:4),1,2),...
                'cdata',Y9,'callback','spm_eeg_review_callbacks(''select'',''add'')',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tooltipstring','Add event to current selection (2 mouse clicks)',...
                'tag','plotEEG');
            set(D.PSD.handles.BUTTONS.sb1,'units','normalized');
            % Selection buttons
            Nevents = length(D.trials.events);
            if Nevents >0
                enab = 'on';
            else
                enab = 'off';
            end
            D.PSD.handles.BUTTONS.sb2 = uicontrol(D.PSD.handles.hfig,'Position',...
                [0.42 0.925 0.05 0.04].*repmat(POS(3:4),1,2),...
                'cdata',Y10,'callback','spm_eeg_review_callbacks(''select'',''goto'',0)',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tooltipstring','Go to closest selected event (forward)','enable',enab,...
                'tag','plotEEG');
            set(D.PSD.handles.BUTTONS.sb2,'units','normalized');
            D.PSD.handles.BUTTONS.sb3 = uicontrol(D.PSD.handles.hfig,'Position',...
                [0.48 0.925 0.05 0.04].*repmat(POS(3:4),1,2),...
                'cdata',Y11,'callback','spm_eeg_review_callbacks(''select'',''goto'',1)',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tooltipstring','Go to closest selected event (backward)','enable',enab,...
                'tag','plotEEG');
            set(D.PSD.handles.BUTTONS.sb3,'units','normalized');
        end

        if ismember(10,objects.list)  % source buttons positions...
            set(D.PSD.handles.BUTTONS.transp,'position',[0.1 0.65 0.025 0.2],...
                'visible','on')
            set(D.PSD.handles.BUTTONS.ct1,'position',[0.74 0.65 0.025 0.2],...
                'visible','on')
            set(D.PSD.handles.BUTTONS.ct2,'position',[0.7675 0.65 0.025 0.2],...
                'visible','on')           
        end
        
        if ismember(11,objects.list)  % display switch (standard/scalp)...
            switch  D.PSD.VIZU.type
                case 1
                    val = 1;
                case 2
                    val = 0;
            end
            D.PSD.handles.BUTTONS.displaySwitch1 = uicontrol(D.PSD.handles.hfig,'Position',...
                [0.42 0.945 0.1 0.02].*repmat(POS(3:4),1,2),...
                'style','radio','string','standard',...
                'callback','spm_eeg_review_callbacks(''visu'',''switch'')',...
                'tooltipstring','Change display type to ''standard''',...
                'userdata',1,'value',val,...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tag','plotEEG');
            set(D.PSD.handles.BUTTONS.displaySwitch1,'units','normalized')
            D.PSD.handles.BUTTONS.displaySwitch2 = uicontrol(D.PSD.handles.hfig,'Position',...
                [0.42 0.925 0.1 0.02].*repmat(POS(3:4),1,2),...
                'style','radio','string','scalp',...
                'callback','spm_eeg_review_callbacks(''visu'',''switch'')',...
                'tooltipstring','Change display type to ''scalp''',...
                'userdata',2,'value',~val,...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tag','plotEEG');
            set(D.PSD.handles.BUTTONS.displaySwitch2,'units','normalized')
        
        end

        if ismember(12,objects.list)  % UPDATE button for data info modifs
            D.PSD.handles.BUTTONS.OKinfo = uicontrol(D.PSD.handles.hfig,'Position',...
                [0.1 0.76 0.1 0.02].*repmat(POS(3:4),1,2),...
                'style','pushbutton','string','update',...
                'callback','spm_eeg_review_callbacks(''get'',''uitable'')',...
                'tooltipstring','!!Update data informations!!',...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tag','plotEEG');
            set(D.PSD.handles.BUTTONS.OKinfo,'units','normalized')
        end
        
        if ismember(13,objects.list)  % switch 'bad' event status
            trN = D.PSD.trials.current;
            if trN>1
                str1 = 'trials = ';
            else
                str1 = 'trial = ';
            end
            status = all([D.trials(trN).bad]);
            if status
                str = ['declare as not bad'];
            else
                str = ['declare as bad'];
            end
            D.PSD.handles.BUTTONS.badEvent = uicontrol(D.PSD.handles.hfig,'Position',...
                [0.82 0.925 0.15 0.04].*repmat(POS(3:4),1,2),...
                'style','pushbutton','string',str,...
                'callback','spm_eeg_review_callbacks(''select'',''bad'')',...
                'tooltipstring',['Change ''bad'' status of ',str1],...
                'BusyAction','cancel',...
                'Interruptible','off',...
                'tag','plotEEG');
            set(D.PSD.handles.BUTTONS.badEvent,'units','normalized')
        end
        

    case 'axes'


        switch objects.what


            case 'standard'

                % create standard axes
                xg = 0:D.Fsample:D.Nsamples;
                xgl = xg./D.Fsample - D.timeOnset;
                D.PSD.handles.axes = axes('position',[0.08 0.08 0.86 0.8],...
                    'parent',D.PSD.handles.hfig,'tag','plotEEG',...
                    'box','on','xtick',xg,'xticklabel',xgl);
                % create global scale axes
                D.PSD.handles.scale = axes('position',[0.875 0.03 0.0445 0.0225],...
                    'xtick',1,'ytick',1,'color',0.95*[1 1 1],...
                    'tag','plotEEG');
                set(D.PSD.handles.scale,'units','normalized');



            case 'scalp'

                % I = channels for which to create axes (eeg/meg/other)
                I = objects.options.channelPlot;
                if ~isempty(I)
                    trN = D.PSD.trials.current(1);
                    try
                        p(1,:) = [D.channels(I).X_plot2D];
                        p(2,:) = [D.channels(I).Y_plot2D];
                    catch % create dummy 2D channel positions
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
                    
                    labels = {D.channels(I).label};
                    if strcmp(D.transform.ID,'time')
                        y = D.data.y(I,:,trN);
                    else
                        y = D.data.y(I,:,:,trN);
                    end
                    miY = min(y(:));
                    maY = max(y(:));
                    % position of plotting area for eeg data in graphics figure
                    Pos = [0.023 0.05 0.95 0.72];
                    % Compute width of display boxes
                    Rxy = 1.5; % ratio of x- to y-axis lengths
                    Npos = size(p,2); % number of positions
                    if Npos > 1
                        % more than 1 channel for display
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
                        D.PSD.handles.fra(i) = uipanel(...
                            'units','normalized','Position',...
                            [p(1,i) p(2,i) 2*Lxrec*Pos(3) 2*Lxrec/Rxy*Pos(4)],...
                            'Parent', D.PSD.handles.hfig,...
                            'userdata',i,...
                            'tag','plotEEG');
                        D.PSD.handles.axes(i) = axes('Position',...
                            [p(1,i) p(2,i) 2*Lxrec*Pos(3) 2*Lxrec/Rxy*Pos(4)],...
                            'NextPlot', 'replacechildren',...
                            'Parent', D.PSD.handles.hfig,...
                            'YLim', [miY maY],...
                            'YLimMode','manual',...
                            'XLim', [1 D.Nsamples],...
                            'XLimMode','manual',...
                            'XTick', [], 'YTick', [], 'Box', 'off',...
                            'userdata',i,...
                            'hittest','off',...
                            'ALimMode','manual',...
                            'tag','plotEEG');
                        set(D.PSD.handles.axes(i),'units','normalized');
                        if ~strcmp(D.transform.ID,'time')
                            set(D.PSD.handles.axes(i),'ylim',...
                                [1 length(D.transform.frequencies)]);
                        end

                    end
                    % create global scale axes
                    if strcmp(D.transform.ID,'time') % only for time data!
                        D.PSD.handles.scale = axes('position',...
                            [0.875 0.03 2*Lxrec*Pos(3) 2*Lxrec/Rxy*Pos(4)],'color',0.95*[1 1 1],...
                            'xtick',1,'xticklabel',[num2str(D.Nsamples.*1e3./D.Fsample),' ms'],...
                            'ytick',1,'userdata',0,'tag','plotEEG',...
                            'hittest','off');
                        set(D.PSD.handles.scale,'units','normalized');
                    end
                end

                
            case 'source'
                % create model comparison axes
                if objects.options.Ninv>1
                    D.PSD.handles.BMCpanel = uipanel('position',[0.42 0.05 0.5 0.25],...
                        'bordertype','beveledin',...
                        'BackgroundColor',0.95*[1 1 1],...
                        'tag','plotEEG');
                    D.PSD.handles.BMCplot = axes('position',[0.5 0.1 0.4 0.15],...
                        'parent',D.PSD.handles.hfig,...
                        'box','on','visible','on',...
                        'tag','plotEEG');
                    set(D.PSD.handles.BMCplot,'hittest','off')
                end
                
                % create textured mesh displaying axes
                miJ = objects.options.miJ;
                maJ = objects.options.maJ;
                D.PSD.handles.axes = axes('position',[0.2 0.6 0.4 0.3],...
                    'parent',D.PSD.handles.hfig,'tag','plotEEG',...
                    'box','on','CLimMode','Manual',...
                    'CLim',[miJ maJ],...
                    'visible','off');


        end
        

        
        
    case 'text'
        
        switch objects.what
            
            case 'data'
                
                [out] = spm_eeg_review_callbacks('get','dataInfo');
                str = out;
                [FS,sf] = spm('FontSize',8);
                D.PSD.handles.infoText = uicontrol('style','text','string',str,...
                    'units','normalized','position',[0.05 0.85 0.8 0.10],...
                    'HorizontalAlignment','left',...
                    'Fontsize',FS,...
                    'BackgroundColor',0.95*[1 1 1],...
                    'tag','plotEEG');
                
            case 'source'
                
                % Text uicontrols for inverse method info
                [out] = spm_eeg_review_callbacks('get','commentInv');
                str = out;
                [FS,sf] = spm('FontSize',8);
                D.PSD.handles.infoText = uicontrol('style','text','string',str,...
                    'units','normalized','position',[0.09 0.1 0.3 0.18],...
                    'HorizontalAlignment','left',...
                    'Fontsize',FS,...
                    'BackgroundColor',0.95*[1 1 1],...
                    'tag','plotEEG');
                
                
                
        end
        
        
        
end