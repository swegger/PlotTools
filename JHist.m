function [ vertices ] = JHist( val, varargin )
%JHist "Rotated" histogram.
%   Default behavior outputs a set of patch vertices. The first column has
%   the X coordinates and the second column has the y coordinates. Pass in
%   an axes handle object to plot directly.

%% Parse additional inputs
p = inputParser;

defaultXVal = zeros(size(val));
checkXVal = @(a) numel(a) == 1 || all(size(a) == size(val));

defaultPlotColor = [0.3 0.3 0.3];
checkPlotColor = @(a) isnumeric(a) && numel(a) == 3;

defaultTargetAxes = [];
checkTargetAxes = @(a) isa(a,'matlab.graphics.axis.Axes');

defaultScaleParam = 1;

addParameter(p,'xVal', ...
    defaultXVal,checkXVal);
addParameter(p,'plotColor', ...
    defaultPlotColor,checkPlotColor);
addParameter(p,'scaleParam', ...
    defaultScaleParam,@isnumeric);
addParameter(p,'targetAxes', ...
    defaultTargetAxes, checkTargetAxes);

parse(p,varargin{:});

xVal = p.Results.xVal;
plotColor = p.Results.plotColor;
scaleParam = p.Results.scaleParam;
targetAxes = p.Results.targetAxes;

%% Calculate histogram
xVals = unique(xVal);

nBins = min(75,round(numel(val)/(numel(xVals)*10)));
responseHist = zeros(nBins,numel(xVals));
edges = zeros(nBins+1,numel(xVals));
for i = 1:numel(xVals)
    [responseHist(:,i), edges(:,i)] = ...
        histcounts(val(xVal == xVals(i)),nBins);
end

if numel(xVals) > 1 && ~isempty(scaleParam)
    scaleFactor = scaleParam*(min(diff(xVals)))/max(responseHist(:));
elseif ~isempty(scaleParam)
    scaleFactor = scaleParam/max(responseHist(:));
end

for i = 1:numel(xVals)
    lineY = [ ...
        reshape([edges(:,i) edges(:,i)]',2*(nBins+1),1); ...
        edges(1,i)];
    lineX = [0; ...
        reshape([responseHist(:,i) responseHist(:,i)]',2*nBins,1); ...
        0; 0];
    lineX = lineX*scaleFactor + xVals(i);
    if ~isempty(targetAxes)
        patch(lineX,lineY,plotColor);
        line([xVals(i) xVals(i)],[min(lineY) max(lineY)], ...
            'color',plotColor/2);
    end
end

vertices = [lineX lineY];

end

