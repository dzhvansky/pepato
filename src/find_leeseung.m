function [W,C,R] = find_leeseung(data,Wini,Cini,N,opt) 
%FIND_LEESEUNG extract non-negative synchronous synergies with Lee & Seung
%algorithm
% 
%   [W,C,R] = find_leeseung(data,Wini,Cini,opt) 
% 
%   find_leeseung.m is currently locked by $Locker$ 
  
%   \\ANDREA2\davel 
%   01-Sep-2004 15:29:38 
%   F:\Experiments\Matlab\synergy\@syn\private\find_leeseung.m 
% 
%   $Revision$ by $Author$ 
%   $Date$ 

[M,K]  = size(data); % images
if nargin<4 || isempty(N)
[M,N]   = size(Wini); % channels x number of synergies
else
    M = size(Wini,1);
end

% initialize C
if nargin<3 || isempty(Cini)
  C = pft_initC(N,K,1);
else
  C = Cini;
end

% initialize filter for "tonic" synergies
if ~isempty(opt.isynfiltcoef) 
  B = fir1(opt.synfiltcoef_filter_par(1),opt.synfiltcoef_filter_par(2));
  A = 1;
end

% data matrix V
V = data;

% SST
Vm = mean(V,2); 
resid = V - Vm*ones(1,size(V,2)); 
%SST = trace(resid'*resid);
SST = trace(resid*resid');
% ssti = zeros(K,1);
% for i=1:K
%  ssti(i) = resid(:,i)'*resid(:,i);
% end
% SST = sum(ssti);

% W
if length(size(Wini)) > 2
    mT = size(Wini,3);
    for i=1:N
        Wtemp(:,:) = Wini(:,i,:);
        W(:,i) = reshape(Wtemp',1,mT*M); % in case of fit, synergies must be inizialized
    end
else
     W = Wini;

end
% W = Wini;

% monitor figures
if opt.plot>1
  h_1 = figure('units','normalized','position',[.05 .12 .5 .8]);
end
if opt.plot>0
  h_2 = figure('units','normalized','position',[.6 .12 .3 .4]);
end
errtot = [];
rsq = [];
inderr = [];

% timing info
tic

%
% general loop
%
niter = opt.niter(1);
if length(opt.niter)==3 % [min iter, monitor window, min R^2 diff]
  niter = opt.niter(1);
  iterwin = opt.niter(2);
  errtol = opt.niter(3);
else
  iterwin = 1;
  errtol = Inf;    
end

% loop while the rsq (abs) difference in the last iterwin iterations is less then errtol
it=0;
while (it<niter || any(abs(diff(rsq(inderr)))>errtol)) && it<opt.nmaxiter
  it = it+1;
  if opt.print
    disp(sprintf('Iteration %i - time elspsed: %6.4f',it,toc))
    tic
    tlast = toc;
  end

  %
  % update C
  %
  %den = W'*W*C;
  den = (W'*W)*C;
  den = den .* (den>0) + (den<=0);
  num = W'*V;
  C = C .* num ./ den;
  if ~isempty(opt.isynfiltcoef) 
    C(opt.isynfiltcoef,:) = filtfilt(B,A,C(opt.isynfiltcoef,:)')';
  end
  
  %
  % update W
  %
  if opt.updateW
    num = V*C';
    den = W*C*C';
    den = den .* (den>0) + (den<=0);
    W = W .* num ./ den;
  end
  
  %
  %display iteration
  %
  if opt.plot>1
    pft_disppar(W,C,h_1)
  end
  

  Vhat = W*C;
  errtot = pft_err(errtot,SST,V,Vhat);
  if opt.plot
    pft_disperr(h_2,errtot,SST,errtol);
  end
  inderr = max(1,length(errtot)-iterwin):length(errtot);
  rsq = 1 - errtot/SST;
  
end

R = rsq;

if opt.plot
  close(h_2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function C = pft_initC(N,K,initype);
% initialize C
switch initype
case 1 % random in [0,1]
  C = rand(N,K);
end

function pft_disppar(W,C,h,labels)
% diplay parameters
figure(h)
N     = size(W,2);
for irow = 1:N
  subplot(N,2,2*(irow-1)+1)
  %imagesc(W(:,irow))
  barh(W(:,irow)), axis ij, axis tight
  title(sprintf('W range= %5.2f %5.2f',min(min(W(:,irow))),max(max(W(:,irow)))))
  if nargin>3
    set(gca,'ytick',1:size(W,1),'yticklabel',labels)
  end
  subplot(N,2,2*(irow-1)+2)
  bar(C(irow,:)), axis tight
end
drawnow

function errtot = pft_err(errtot,sst,V,Vhat)
% compute error
resid = V-Vhat;
ee = trace(resid*resid');
errtot = [errtot ee];

function pft_disperr(h,errtot,sst,errtol)
% diplay error
figure(h)
subplot(2,1,1)
rsq = 1 - errtot/sst;
plot(rsq)
title(sprintf('R^2 = %f',rsq(end)))
h1 = gca;
subplot(2,1,2)
drsq = diff(rsq);
if ~isempty(drsq) 
  plot(2:length(rsq),abs(drsq),'r')
  set(gca,'xlim',xlim,'yscale','log')
  title(sprintf('diff R^2 = %e',drsq(end)))
  line(xlim,errtol*[1 1])
end
drawnow

