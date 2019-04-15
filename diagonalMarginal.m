function [n, edges, ...
    dataH, patchH, zAxH, nAxH, ztextH, ntextH, zAxTickH, nAxTickH, unityH] = ...
    diagonalMarginal(x,y,varargin)
%% diagonalMarginal
%
%   diagonalMarginal(x,y)
%
%
%%

%% Defaults

%% Parse inputs
Parser = inputParser;

addRequired(Parser,'x')
addRequired(Parser,'y')
addParameter(Parser,'theta',-45)
addParameter(Parser,'nscale',1)
addParameter(Parser,'ztickN',3)
addParameter(Parser,'binN',21)
addParameter(Parser,'edges',NaN)
addParameter(Parser,'zticks',NaN)
addParameter(Parser,'T',NaN)
addParameter(Parser,'offsetFactor',0.01)
addParameter(Parser,'axVals',NaN)

parse(Parser,x,y,varargin{:})

x = Parser.Results.x;
y = Parser.Results.y;
theta = Parser.Results.theta;
nscale = Parser.Results.nscale;
ztickN = Parser.Results.ztickN;
binN = Parser.Results.binN;
edges = Parser.Results.edges;
zticks = Parser.Results.zticks;
T = Parser.Results.T;
offsetFactor = Parser.Results.offsetFactor;
axVals = Parser.Results.axVals;


%% Generate marginal frequency data, statistics
z = x-y;

if any(isnan(edges))
    edges = linspace(-ceil(max(abs(z))),ceil(max(abs(z))),binN);
end
[n, edges2] = histcounts(z,[edges edges(end)+(edges(2)-edges(1))/2]);
N = n/sum(n);
edges2(end) = edges2(end) + (edges(2)-edges(1))/2;

if any(isnan(zticks))
    zticks = linspace(-floor(max(abs(z))),floor(max(abs(z))),ztickN);
end

minval = min([x(:); y(:)]);
maxval = max([x(:); y(:)]);

zbar = nanmean(z);
z95ci = sqrt(nanvar(z)/numel(z))*1.96;

%% Set transformation matrices
if any(isnan(T))
    T = [maxval maxval];
end
R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];

%% Generate patch object
A = ([ reshape([edges2(:) edges2(:)]',2*length(edges2),1); edges2(1) ] - (edges2(2)-edges2(1))/2)...
    /sqrt(2);
B = nscale*[ 0; reshape([N(:) N(:)]',2*length(N),1); 0; 0];
C = [A B];
Ct = [R*C']'  + repmat(T,[size(C,1),1]);

%% Set axes, ticks, labels for marginal plot
zline = [min(A) -offsetFactor*sqrt(sum(T.^2)); max(A) -offsetFactor*sqrt(sum(T.^2))];
zticks2(:,:,1) = [zticks(:)/sqrt(2) repmat(-offsetFactor*sqrt(sum(T.^2)),length(zticks),1)];
zticks2(:,:,2) = [zticks(:)/sqrt(2) repmat(-5*offsetFactor*sqrt(sum(T.^2)),length(zticks),1)];
zt = (R*zline')' + repmat(T,[size(zline,1),1]);
for zi = 1:ztickN
    ztickst{zi} = [ (R*zticks2(zi,:,1)')' + T; (R*zticks2(zi,:,2)')' + T];
end

nline = [min(A)-offsetFactor*sqrt(sum(T.^2)) 0;...
    min(A)-offsetFactor*sqrt(sum(T.^2)) max(N)*nscale];
nt = (R*nline')' + repmat(T,[size(nline,1),1]);
nticks(:,:,1) = [min(A)-offsetFactor*sqrt(sum(T.^2)) 0;...
                 min(A)-offsetFactor*sqrt(sum(T.^2)) max(N)*nscale];
nticks(:,:,2) = [min(A)-5*offsetFactor*sqrt(sum(T.^2)) 0;...
                 min(A)-5*offsetFactor*sqrt(sum(T.^2)) max(N)*nscale];
for ni = 1:2
    ntickst{ni} = [ (R*nticks(ni,:,1)')' + T; (R*nticks(ni,:,2)')' + T];
end
nlabels(1) = 0;
nlabels(2) = max(n);
             
zbarline = [zbar-offsetFactor*sqrt(sum(T.^2)) 0;...
    zbar-offsetFactor*sqrt(sum(T.^2)) max(N)*nscale];
zbart = (R*zbarline')' + repmat(T,[size(zbarline,1),1]);

zCIplusline = [zbar+z95ci-offsetFactor*sqrt(sum(T.^2)) 0;...
    zbar+z95ci-offsetFactor*sqrt(sum(T.^2)) max(N)*nscale];
zCIplusT = (R*zCIplusline')' + repmat(T,[size(zCIplusline,1),1]);

zCIminusline = [zbar-z95ci-offsetFactor*sqrt(sum(T.^2)) 0;...
    zbar-z95ci-offsetFactor*sqrt(sum(T.^2)) max(N)*nscale];
zCIminusT = (R*zCIminusline')' + repmat(T,[size(zCIminusline,1),1]);

%% Plot the output

% Scatter plot
dataH = plot(x,y,'o','Color',[1 1 1],'MarkerFaceColor',[0 0 0]);
hold on
if any(isnan(axVals))
    axis([minval maxval+1.5*T(1) minval maxval+1.5*T(2)]);
else
    axis(axVals);
end
ax = axis;
unityH = plot(ax([1,2]),ax([3,4]),'k--');
axis square

% Marginal axes
zAxH = plot(zt(:,1),zt(:,2),'k-');
nAxH = plot(nt(:,1),nt(:,2),'k-');
for zi = 1:ztickN
    zAxTickH(zi) = plot(ztickst{zi}(:,1),ztickst{zi}(:,2),'k-');
    ztextH(zi) = text(ztickst{zi}(2,1),ztickst{zi}(2,2),num2str(zticks(zi)));
    ztextH(zi).HorizontalAlignment = 'center';
    ztextH(zi).VerticalAlignment = 'top';
    ztextH(zi).Rotation = theta;
end
for ni = 1:2
    nAxTickH(ni) = plot(ntickst{ni}(:,1),ntickst{ni}(:,2),'k-');
    ntextH(ni) = text(ntickst{ni}(2,1),ntickst{ni}(2,2),num2str(nlabels(ni)));
    ntextH(ni).HorizontalAlignment = 'right';
    ntextH(ni).VerticalAlignment = 'middle';
    ntextH(ni).Rotation = theta;
end


% Marginal histogram
patchH = patch(Ct(:,1),Ct(:,2),[0 0 0]);
patchH.EdgeColor = 'none';

% Plot mean +/- 95 CI
plot(zbart(:,1),zbart(:,2),'r-')
plot(zCIplusT(:,1),zCIplusT(:,2),'r-')
plot(zCIminusT(:,1),zCIminusT(:,2),'r-')