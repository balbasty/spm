function [MDP] = spm_MDP_VB_X(MDP,OPTIONS)
% active inference and learning using variational Bayes (factorised)
% FORMAT [MDP] = spm_MDP_VB_X(MDP,OPTIONS)
%
% MDP.V(T - 1,P,F)      - P allowable policies (T - 1 moves) over F factors
% or
% MDP.U(1,P,F)          - P allowable actions at each move
% MDP.T                 - number of outcomes
%
% MDP.A{G}(O,N1,...,NF) - likelihood of O outcomes given hidden states
% MDP.B{F}(NF,NF,MF)    - transitions among states under MF control states
% MDP.C{G}(O,T)         - prior preferences over O outsomes in modality G
% MDP.D{F}(NF,1)        - prior probabilities over initial states
%
% MDP.a{G}              - concentration parameters for A
% MDP.b{F}              - concentration parameters for B
% MDP.d{F}              - concentration parameters for D
%
% optional:
% MDP.s(F,T)            - vector of true states - for each hidden factor
% MDP.o(G,T)            - vector of outcome     - for each outcome modality
% MDP.u(F,T - 1)        - vector of actions     - for each hidden factor
%
% MDP.alpha             - precision � action selection [16]
% MDP.beta              - precision over precision (Gamma hyperprior - [1])
% MDP.tau               - time constant for gradient descent
%
% OPTIONS.plot          - switch to suppress graphics:  (default: [0])
% OPTIONS.gamma         - switch to suppress precision: (default: [0])
%
% produces:
%
% MDP.P(M1,...,MF,T)    - probability of emitting action M1,.. over time
% MDP.Q{F}(NF,T,P)      - expected hidden states under each policy
% MDP.X{F}(NF,T)        - and Bayesian model averages over policies
% MDP.R(P,T)            - conditional expectations over policies
%
% MDP.un          - simulated neuronal encoding of hidden states
% MDP.xn          - simulated neuronal encoding of policies
% MDP.wn          - simulated neuronal encoding of precision (tonic)
% MDP.dn          - simulated dopamine responses (phasic)
% MDP.rt          - simulated reaction times
%
% This routine provides solutions of active inference (minimisation of
% variational free energy) using a generative model based upon a Markov
% decision process. The model and inference scheme is formulated
% in discrete space and time. This means that the generative model (and
% process) are  finite state machines or hidden Markov models whose
% dynamics are given by transition probabilities among states and the
% likelihood corresponds to a particular outcome conditioned upon
% hidden states.
%
% This implementation equips agents with the prior beliefs that they will
% maximise expected free energy: expected free energy is the free energy
% of future outcomes under the posterior predictive distribution. This can
% be interpreted in several ways � most intuitively as minimising the KL
% divergence between predicted and preferred outcomes (specified as prior
% beliefs) � while simultaneously minimising ambiguity.
%
% This particular scheme is designed for any allowable policies or control
% sequences specified in MDP.V. Constraints on allowable policies can limit
% the numerics or combinatorics considerably. Further, the outcome space
% and hidden states can be defined in terms of factors; corresponding to
% sensory modalities and (functionally) segregated representations,
% respectively. This means, for each factor or subset of hidden states
% there are corresponding control states that determine the transition
% probabilities.
%
% This specification simplifies the generative model, allowing a fairly
% exhaustive model of potential outcomes. In brief, the agent encodes
% beliefs about hidden states in the past (and in the future) conditioned
% on each policy. The conditional expectations determine the (path
% integral) of free energy that then determines the prior over policies.
% This prior is used to create a predictive distribution over outcomes,
% which specifies the next action.
%
% In addition to state estimation and policy selection, the scheme also
% updates model parameters; including the state transition matrices,
% mapping to outcomes and the initial state. This is useful for learning
% the context.
%
% See also:spm_MDP, which uses multiple future states and a mean field
% approximation for control states � but allows for different actions
% at all times (as in control problems).
%
% See also: spm_MDP_game_KL, which uses a very similar formulation but just
% maximises the KL divergence between the posterior predictive distribution
% over hidden states and those specified by preferences or prior beliefs.
%__________________________________________________________________________
% Copyright (C) 2005 Wellcome Trust Centre for Neuroimaging

% Karl Friston
% $Id: spm_MDP_VB_X.m 6803 2016-06-06 09:45:33Z karl $


% deal with a sequence of trials
%==========================================================================

% options
%--------------------------------------------------------------------------
try, OPTIONS.plot;  catch, OPTIONS.plot  = 0; end
try, OPTIONS.gamma; catch, OPTIONS.gamma = 0; end

% if there are multiple trials ensure that parameters are updated
%--------------------------------------------------------------------------
if length(MDP) > 1
    
    OPTS      = OPTIONS;
    OPTS.plot = 0;
    for i = 1:length(MDP)
        
        % update concentration parameters
        %------------------------------------------------------------------
        if i > 1
            try,  MDP(i).a = OUT(i - 1).a; end
            try,  MDP(i).b = OUT(i - 1).b; end
            try,  MDP(i).d = OUT(i - 1).d; end
        end
        
        % solve this trial
        %------------------------------------------------------------------
        OUT(i) = spm_MDP_VB_X(MDP(i),OPTS);
        
        % Bayesian model reduction
        %------------------------------------------------------------------
        if isfield(OPTIONS,'BMR')
            OUT(i) = spm_MDP_VB_sleep(OUT(i),OPTIONS.BMR);
        end
        
    end
    MDP = OUT;
    
    % plot summary statistics - over trials
    %----------------------------------------------------------------------
    if OPTIONS.plot
        if ishandle(OPTIONS.plot)
            figure(OPTIONS.plot); clf
        else
            spm_figure('GetWin','MDP'); clf
        end
        spm_MDP_VB_game(MDP)
    end
    return
end


% set up and preliminaries
%==========================================================================
try
    V = MDP.U;                      % allowable actions (1,Np)
    T = MDP.T;                      % number of transitions
catch
    V = MDP.V;                      % allowable policies (T - 1,Np)
    T = size(MDP.V,1) + 1;          % number of transitions
end

% numbers of transitions, policies and states
%--------------------------------------------------------------------------
Ng  = numel(MDP.A);                 % number of outcome factors
Nf  = numel(MDP.B);                 % number of hidden state factors
Np  = size(V,2);                    % number of allowable policies
for f = 1:Nf
    Ns(f) = size(MDP.B{f},1);       % number of hidden states
    Nu(f) = size(MDP.B{f},3);       % number of hidden controls
end
for g = 1:Ng
    No(g) = size(MDP.A{g},1);       % number of outcomes
end
p0  = exp(-16);                     % smallest probability
q0  = 1/16;                         % smallest probability


% parameters of generative model and policies
%==========================================================================

% likelihood model (for a partially observed MDP implicit in G)
%--------------------------------------------------------------------------
for g = 1:Ng
    
    MDP.A{g}  = spm_norm(MDP.A{g});
    
    % parameters (concentration parameters): A
    %----------------------------------------------------------------------
    if isfield(MDP,'a')
        A{g}  = spm_norm(MDP.a{g});
        qA{g} = spm_psi(MDP.a{g} + q0);
        wA{g} = 1./spm_cum(MDP.a{g}) - 1./(MDP.a{g} + p0);
        wA{g} = wA{g}.*(MDP.a{g} > 0);
    else
        A{g}  = MDP.A{g};
        qA{g} = log(A{g} + p0);
    end
    
    % entropy
    %----------------------------------------------------------------------
    H{g} = spm_ent(qA{g});
    
end

% transition probabilities (priors)
%--------------------------------------------------------------------------
for f = 1:Nf
    for j = 1:Nu(f)
        
        % controlable transition probabilities
        %------------------------------------------------------------------
        MDP.B{f}(:,:,j) = spm_norm(MDP.B{f}(:,:,j));
        
        % parameters (concentration parameters): B
        %------------------------------------------------------------------
        if isfield(MDP,'b')
            sB{f}(:,:,j) = spm_norm(MDP.b{f}(:,:,j) + p0);
            rB{f}(:,:,j) = spm_norm(MDP.b{f}(:,:,j)' + p0);
        else
            sB{f}(:,:,j) = spm_norm(MDP.B{f}(:,:,j)  + p0);
            rB{f}(:,:,j) = spm_norm(MDP.B{f}(:,:,j)' + p0);
        end
        
    end
end


% priors over initial hidden states - concentration parameters
%--------------------------------------------------------------------------
for f = 1:Nf
    if isfield(MDP,'d')
        D{f} = spm_norm(MDP.d{f} + p0);
    elseif isfield(MDP,'D')
        D{f} = spm_norm(MDP.D{f} + p0);
    else
        D{f} = spm_norm(ones(Ns(f),1));
    end
end


% prior preferences (log probabilities) : C
%--------------------------------------------------------------------------
for g = 1:Ng
    if isfield(MDP,'C')
        Vo{g} = MDP.C{g};
    else
        Vo{g} = zeros(No(g),1);
    end
    
    % assume constant preferences, if only final states are specified
    %----------------------------------------------------------------------
    if size(Vo{g},2) == 1
        Vo{g} = repmat(Vo{g},1,T);
    end
    Vo{g}     = log(spm_softmax(Vo{g}));
end

% precision defaults
%--------------------------------------------------------------------------
try, alpha = MDP.alpha; catch, alpha = 16;   end
try, beta  = MDP.beta;  catch, beta  = 1;    end
try, tau   = MDP.tau;   catch, tau   = 1/Nf; end

% initialise
%--------------------------------------------------------------------------
Ni    = 16;                         % number of VB iterations
rt    = zeros(1,T);                 % reaction times
wn    = zeros(T*Ni,1);              % simulated DA responses
for f = 1:Nf
    
    % true states
    %----------------------------------------------------------------------
    try
        s(f,1) = MDP.s(f,1);
    catch
        s(f,1) = find(rand < cumsum(D{f}),1);
    end
    
    % initialise posteriors over states
    %----------------------------------------------------------------------
    xn{f} = zeros(Ni,Ns(f),T,T,Np) + 1/Ns(f);
    x{f}  = zeros(Ns(f),T,Np)      + 1/Ns(f);
    X{f}  = repmat(D{f},1,T);
    for k = 1:Np
        x{f}(:,1,k) = D{f};
    end
    
end

% initialise posteriors over polices and action
%--------------------------------------------------------------------------
P  = zeros([Nu,(T - 1)]);
un = zeros(Np,T*Ni);
u  = zeros(Np,T - 1);
a  = zeros(Nf,T - 1);


% expected rate parameter
%--------------------------------------------------------------------------
p     = 1:Np;                       % allowable policies
qbeta = beta;                       % initialise rate parameters
gu    = zeros(1,T) + 1/qbeta;       % posterior precision (policy)

% solve
%==========================================================================
for t = 1:T
    
    % observed state
    %======================================================================
    if isfield(MDP,'link')
        
        mdp   = MDP.MDP;
        link  = MDP.link;
        [i,j] = find(link);
        for f = 1:Nf
            xq{f} = X{f}(:,t);
        end
        
        % priors over states (of subordinate level)
        %------------------------------------------------------------------
        for g = 1:length(j)
            mdp.D{i(g)} = spm_dot(A{j(g)},xq);
        end
        
        % store this level get (probabilistic) outcome
        %------------------------------------------------------------------
        mdp        = spm_MDP_VB_X(mdp);
        MDP.mdp(t) = mdp;
    else
        link   = sparse(Ng,Nf);
    end
    
    % outcomes
    %----------------------------------------------------------------------
    for g = 1:Ng
        
        % posterior states and outcome (from subordinate level)
        %------------------------------------------------------------------
        if any(link(:,g))
            o(g,t) = mdp.s(i(g),1);
            O{g,t} = mdp.X{i(g),1};
        else
            
            % outcome at this level
            %--------------------------------------------------------------
            try
                o(g,t) = MDP.o(g,t);
                O{g,t} = sparse(o(g,t),1,1,No(g),1);
            catch
                for g = 1:Ng
                    ind    = num2cell(s(:,t));
                    po     = MDP.A{g}(:,ind{:});
                    o(g,t) = find(rand < cumsum(po),1);
                    O{g,t} = sparse(o(g,t),1,1,No(g),1);
                end
            end
        end
    end
    
    
    % Variational updates
    %======================================================================
    
    % processing time and reset
    %----------------------------------------------------------------------
    tstart = tic;
    for f = 1:Nf
        x{f} = spm_softmax(log(x{f})/4);
    end
    
    % Variational updates (hidden states) under sequential policies
    %======================================================================
    S     = size(V,1) + 1;
    for i = 1:Ni
        F     = zeros(Np,S);
        G     = zeros(Np,S);
        for k = p
            for j = 1:S
                for f = 1:Nf
                    
                    % evaluate free energy and gradients (v = dFdx)
                    %======================================================
                    ind    = 1:Nf;
                    ind(f) = [];
                    xq     = cell(1,Nf - 1);
                    for  q = 1:numel(ind)
                        xq{q} = x{ind(q)}(:,j,k);
                    end
                    ind = [1 (ind + 1)];
                    
                    % marginal likelihood over outcome factors
                    %------------------------------------------------------
                    v     = 0;
                    if j <= t
                        for g = 1:Ng
                            Aq = spm_dot(A{g},[O(g,j) xq],ind);
                            v  = v + log(Aq(:) + p0);
                        end
                    end
                    
                    % entropy term and belief update
                    %------------------------------------------------------
                    sx     = x{f}(:,j,k);
                    qx     = log(sx);
                    v      = v - qx;
                                        
                    % emprical priors
                    %------------------------------------------------------
                    if j == 1, v = v + log(D{f});                                    end
                    if j >  1, v = v + log(sB{f}(:,:,V(j - 1,k,f))*x{f}(:,j - 1,k)); end
                    if j <  S, v = v + log(rB{f}(:,:,V(j    ,k,f))*x{f}(:,j + 1,k)); end
                    
                    % (negative) free energy and update
                    %------------------------------------------------------
                    v      = v/Nf;
                    dF     = sx'*v;
                    dFdx   = v - dF;
                    sx     = spm_softmax(qx + dFdx/tau/8);
                    
                    % store update neuronal activity
                    %------------------------------------------------------
                    x{f}(:,j,k)      = sx;
                    xn{f}(i,:,j,t,k) = sx;
                    
                    % accumulate free energy
                     %------------------------------------------------------
                    F(k,j) = F(k,j) + dF;
                    
                end
            end
            if sum(F(k,:),2) < G(k)
                
            end
            disp(sum(F(k,:),2) - G(k))
            G(k) = sum(F(k,:),2);
        end
    end
    
    % (negative path integral of) free energy of policies (Q)
    %======================================================================
    Q     = zeros(Np,S);
    for k = p
        for j = 1:S
            
            % get expected states for this policy and time
            %--------------------------------------------------------------
            xq    = cell(1,Nf);
            for f = 1:Nf
                xq{f} = x{f}(:,j,k);
            end
            
            % (negative) expected free energy
            %==============================================================
            for g = 1:Ng
                
                % uncertainty about outcomes
                %----------------------------------------------------------
                qo     = spm_dot(A{g},xq);
                Q(k,j) = Q(k,j) + qo'*(Vo{g}(:,j) - log(qo + p0));
                Q(k,j) = Q(k,j) + spm_dot(H{g},xq);
                
                % uncertainty about parameters
                %----------------------------------------------------------
                if isfield(MDP,'a')
                    Q(k,j) = Q(k,j) - spm_dot(wA{g},[qo xq]);
                end
                
            end
            
        end
    end
    
    % eliminate unlikely policies
    %----------------------------------------------------------------------
    SF = sum(F,2);
    SQ = sum(Q,2);
    if ~isfield(MDP,'U')
        p = p((SF(p) - max(SF(p))) > -3);
    else
        OPTIONS.gamma = 1;
    end
    
    % variational updates - policies and precision
    %======================================================================
    for i = 1:Ni
        
        % posterior and prior beliefs about policies
        %----------------------------------------------------------------------
        qu = spm_softmax(gu(t)*SQ(p) + SF(p));
        pu = spm_softmax(gu(t)*SQ(p));
        
        % precision (gu) with free energy gradients (v = -dF/dw)
        %------------------------------------------------------------------
        if OPTIONS.gamma
            gu(t) = 1/beta;
        else
            eg    = (qu - pu)'*SQ(p);
            dFdg  = qbeta - beta + eg;
            qbeta = qbeta - dFdg/2;
            gu(t) = 1/qbeta;
        end
        
        % simulated dopamine responses (precision at each iteration)
        %------------------------------------------------------------------
        n       = (t - 1)*Ni + i;
        u(p,t)  = qu;
        wn(n,1) = gu(t);
        un(p,n) = qu;
        
    end
    
    
    % Bayesian model averaging of hidden states (over policies)
    %----------------------------------------------------------------------
    for f = 1:Nf
        for i = 1:S
            X{f}(:,i) = reshape(x{f}(:,i,:),Ns(f),Np)*u(:,t);
        end
    end
    
    % processing time
    %----------------------------------------------------------------------
    rt(t) = toc(tstart);
    
    
    % action selection and sampling of next state (outcome)
    %======================================================================
    if t < T
        
        % posterior potential for (allowable) actions (for each modality)
        %==================================================================
        
        % unique combinations of actions
        %------------------------------------------------------------------
        up    = unique(shiftdim(V(t,p,:),1),'rows');
        
        % predicted hidden states at the next time step
        %------------------------------------------------------------------
        for f = 1:Nf
            xp{f} = X{f}(:,t + 1);
        end
        
        % predicted hidden states under each action
        %------------------------------------------------------------------
        Pu    = zeros(Nu);
        for i = 1:size(up,1)
            
            for f = 1:Nf
                xq{f} = sB{f}(:,:,up(i,f))*X{f}(:,t);
            end
            
            % accumulate action potential over outcomes
            %--------------------------------------------------------------
            for g = 1:Ng
                
                % predicted outcome
                %----------------------------------------------------------
                po = spm_dot(A{g},xp);
                qo = spm_dot(A{g},xq);
                dP = (log(po + p0) - log(qo + p0))'*qo;
                
                % augment action potential
                %----------------------------------------------------------
                sub        = num2cell(up(i,:));
                Pu(sub{:}) = Pu(sub{:}) + dP + 16;
                
            end
        end
        
        % action selection - a softmax function of action potential
        %------------------------------------------------------------------
        sub         = repmat({':'},1,Nf);
        Pu(:)       = spm_softmax(alpha*Pu(:));
        P(sub{:},t) = Pu;
        
        % next action - sampled from beliefs about control states
        %------------------------------------------------------------------
        try
            a(:,t)  = MDP.u(:,t);
        catch
            ind     = find(rand < cumsum(Pu(:)),1);
            a(:,t)  = spm_ind2sub(Nu,ind);
        end
        
        % next sampled state - based on the current action
        %------------------------------------------------------------------
        try
            s(:,t + 1) = MDP.s(:,t + 1);
        catch
            for f = 1:Nf
                ps         = MDP.B{f}(:,s(f,t),a(f,t));
                s(f,t + 1) = find(rand < cumsum(ps),1);
            end
        end
        
        % next expected precision
        %------------------------------------------------------------------
        gu(1,t + 1)   = gu(t);
        
        % update policy and states for moving policies
        %------------------------------------------------------------------
        if isfield(MDP,'U')
            
            for f = 1:Nf
                V(t,:,f) = a(f,t);
            end
            for j = 1:size(MDP.U,1)
                if (t + j) < T
                    V(t + j,:,:) = MDP.U(j,:,:);
                end
            end
            
            % and reinitialise expectations about hidden states
            %--------------------------------------------------------------
            for f = 1:Nf
                for k = 1:Np
                    x{f}(:,:,k) = 1/Ns(f);
                end
            end
            
        end
    end
end

% learning
%==========================================================================
for t = 1:T
    
    % mapping from hidden states to outcomes: a
    %----------------------------------------------------------------------
    if isfield(MDP,'a')
        for g = 1:Ng
            da     = sparse(o(g,t),1,1,No(g),1);
            for  f = 1:Nf
                da = spm_cross(da,X{f}(:,t));
            end
            da       = da.*(MDP.a{g} > 0);
            MDP.a{g} = MDP.a{g} + da;
            MDP.Fa   = spm_vec(da)'*spm_vec(qA{g}) - sum(spm_vec(spm_betaln(MDP.a{g})));
        end
    end
    
    % mapping from hidden states to hidden states: b(u)
    %----------------------------------------------------------------------
    if isfield(MDP,'b') && t > 1
        for f = 1:Nf
            for k = 1:Np
                v   = V(t - 1,k,f);
                db  = u(k,t - 1)*x{f}(:,t,k)*x{f}(:,t - 1,k)';
                MDP.b{f}(:,:,v) = MDP.b{f}(:,:,v) + db.*(MDP.b{f}(:,:,v) > 0);
            end
        end
    end
    
end

% initial hidden states: d
%--------------------------------------------------------------------------
if isfield(MDP,'d')
    for f = 1:Nf
        i = MDP.d{f} > 0;
        MDP.d{f}(i) = MDP.d{f}(i) + X{f}(i,1);
    end
end

% simulated dopamine (or cholinergic) responses
%--------------------------------------------------------------------------
dn    = 8*gradient(wn) + wn/8;

% Bayesian model averaging of expected hidden states over policies
%--------------------------------------------------------------------------
for f = 1:Nf
    Xn{f}    = zeros(Ni,Ns(f),T,T);
    for i = 1:T
        for k = 1:Np
            Xn{f}(:,:,:,i) = Xn{f}(:,:,:,i) + xn{f}(:,:,:,i,k)*u(k,i);
        end
    end
end

% use penultimate beliefs about moving policies
%--------------------------------------------------------------------------
if isfield(MDP,'U')
    qu     = u(p,T - 1);
    u(p,T) = qu;
end

% evaluate free action
%==========================================================================
SG      = gu(t)*SQ(p);
Z       = sum(exp(SG));
MDP.Fu  = qu'*log(qu);                 % confidence (action)
MDP.Fq  = log(Z) - qu'*SG;             % free energy of policies
MDP.Fs  =        - qu'*SF(p);          % free energy of hidden states
MDP.Fg  = beta*gu(t) - log(gu(t));     % free energy of precision

% assemble results and place in NDP structure
%--------------------------------------------------------------------------
MDP.P   = P;              % probability of action at time 1,...,T - 1
MDP.Q   = x;              % conditional expectations over N hidden states
MDP.X   = X;              % Bayesian model averages over T outcomes
MDP.R   = u;              % conditional expectations over policies
MDP.V   = V;              % policies
MDP.o   = o;              % outcomes at 1,...,T
MDP.s   = s;              % states   at 1,...,T
MDP.u   = a;              % action   at 1,...,T - 1
MDP.w   = gu;             % posterior expectations of precision (policy)
MDP.C   = Vo;             % utility

MDP.un  = un;             % simulated neuronal encoding of policies
MDP.xn  = Xn;             % simulated neuronal encoding of hidden states
MDP.wn  = wn;             % simulated neuronal encoding of precision
MDP.dn  = dn;             % simulated dopamine responses (deconvolved)
MDP.rt  = rt;             % simulated reaction time (seconds)


% plot
%==========================================================================
if OPTIONS.plot
    if ishandle(OPTIONS.plot)
        figure(OPTIONS.plot); clf
    else
        spm_figure('GetWin','MDP'); clf
    end
    spm_MDP_VB_trial(MDP)
end


function A = spm_norm(A)
% normalisation of a probability transition matrix (columns)
%--------------------------------------------------------------------------
for i = 1:size(A,2)
    for j = 1:size(A,3)
        for k = 1:size(A,4)
            for l = 1:size(A,5)
                A(:,i,j,k,l) = A(:,i,j,k,l)/sum(A(:,i,j,k,l),1);
            end
        end
    end
end

function A = spm_cum(A)
% summation of a probability transition matrix (columns)
%--------------------------------------------------------------------------
for i = 1:size(A,2)
    for j = 1:size(A,3)
        for k = 1:size(A,4)
            for l = 1:size(A,5)
                A(:,i,j,k,l) = sum(A(:,i,j,k,l),1);
            end
        end
    end
end

function A = spm_psi(A)
% normalisation of a probability transition rate matrix (columns)
%--------------------------------------------------------------------------
for i = 1:size(A,2)
    for j = 1:size(A,3)
        for k = 1:size(A,4)
            for l = 1:size(A,5)
                A(:,i,j,k,l) = psi(A(:,i,j,k,l)) - psi(sum(A(:,i,j,k,l)));
            end
        end
    end
end

function H = spm_ent(A)
% normalisation of a probability transition matrix (columns)
%--------------------------------------------------------------------------
for i = 1:size(A,2)
    for j = 1:size(A,3)
        for k = 1:size(A,4)
            for l = 1:size(A,5)
                H(i,j,k,l) = spm_softmax(A(:,i,j,k,l))'*A(:,i,j,k,l);
            end
        end
    end
end

function sub = spm_ind2sub(siz,ndx)
% subscripts from linear index
%--------------------------------------------------------------------------
n = numel(siz);
k = [1 cumprod(siz(1:end-1))];
for i = n:-1:1,
    vi       = rem(ndx - 1,k(i)) + 1;
    vj       = (ndx - vi)/k(i) + 1;
    sub(i,1) = vj;
    ndx      = vi;
end


return

% NOTES: gradient checks for hidden states
%==========================================================================
mdp_F  = @(qx,v)spm_softmax(qx)'*(log(v) - log(spm_softmax(qx)));
dFdx   = spm_diff(mdp_F,qx,v,1);
dFdxx  = spm_diff(mdp_F,qx,v,[1 1]);
dFdx   = sx.*(e - sx'*e);

% NOTES: gradient checks for precision map
%==========================================================================
g      = 1/qbeta;
mdp_F  = @(g,Q,p,beta) qu'*log(spm_softmax(g*Q(p))) - (beta*g - log(g));
dFdg   = spm_diff(mdp_F,g,Q,p,beta,1);
dFdg   = qbeta - beta + (qu - spm_softmax(g*Q(p)))'*Q(p);



