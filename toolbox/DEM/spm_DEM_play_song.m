function [Y,FS] = spm_DEM_play_song(qU,T);
% displays the song-bird images specified by the states in qU
% FORMAT [Y,FS] = spm_DEM_play_song(qU,T);
%
% qU   - conditional moments of states (see spm_DEM)
% T    - number of seconds over which to play the sound
%
% Y    - sound image
% FS   - sampling rate (Hz)
%
% A button press on the spectrogram will play the song
%__________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging
 
% Karl Friston
% $Id: spm_DEM_play_song.m 1380 2008-04-11 18:55:18Z karl $
 
% load frequency modes
%--------------------------------------------------------------------------
try
    T;
catch
    T = 2;
end
 
 
% create sound image
%==========================================================================
v      = qU.v{1};
[Nm m] = size(v);
 
% frequencies
%--------------------------------------------------------------------------
Hf  = 5000;                                % upper frequency (Hz)
Lf  = 2000;                                % lower frequency (Hz)
Bf  = 500;                                 % boundary frequency (Hz)
Nf  = 64;                                  % number of frequency bin
Hz  = linspace(Lf,Hf,64);                  % frequencies
FS  = 2*Hz(end);                           % sampling rate (Hz)
k   = Hz/Hz(1);                            % cycles per window
n   = FS/Hz(1);                            % window length
N   = FS*T;                                % number of sonogram bins
R   = fix(N/m);                            % interpolation factor
N   = R*m;
pst = [1:N]/FS;                            % peristimulus time
sf  = 2*64^2;                              % dispersion of frequencies
 
 
% resample temporal modes
%--------------------------------------------------------------------------
for i = 1:Nm
    V(i,:) = interp(v(i,:),R);
end
            
% create sonogram sound
%--------------------------------------------------------------------------
b     = V(1,:);                            % amplitude modulation
f     = V(2,:);                            % frequency modulation
b     = exp(abs(b)/3);
b     = b/max(b);
f     = f - min(f);
f     = (Hf - Lf - Bf - Bf)*f/max(f) + Lf + Bf;

S     = sparse(Nf,N);
for i = 1:N
    s      = b(i)*exp(-(Hz - f(i)).^2/sf);
    S(:,i) = sparse(s.*(s > exp(-4)));
end
 
 
% inverse Fourier transform
%--------------------------------------------------------------------------
Y   = spm_iwft(S,k,n);
Y   = Y/max(Y);

 
% Graphics
%==========================================================================
imagesc(pst,Hz,abs(S))
axis xy
xlabel('Time (sec)')
ylabel('Frequency (Hz)')
 
% set sound data
%--------------------------------------------------------------------------
h      = get(gca,'Children');
set(h(1),'Userdata',{Y,FS})
set(h(1),'ButtonDownFcn','spm_DEM_ButtonDownFcn')
