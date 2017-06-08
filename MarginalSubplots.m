function h = MarginalSubplots(varargin)
%% MarginalSubplots
%
%%

%% Defaults

%% Parse inputs
Parser = inputParser;

addParameter(Parser,'Handles',NaN)
addParameter(Parser,'xMargin',0.10)
addParameter(Parser,'xHeight',0.20)
addParameter(Parser,'yMargin',0.10)
addParameter(Parser,'yHeight',0.20)

parse(Parser,varargin{:})

xMargin = Parser.Results.xMargin;
xHeight = Parser.Results.xHeight;
yMargin = Parser.Results.yMargin;
yHeight = Parser.Results.yHeight;

%% Open figure
ssz = get(0,'screensize');
aspectRatio = ssz(3)/ssz(4);
fh = figure('Units','normalized','Position',[0.1 0.1 0.3 0.3*aspectRatio]);

%% Generate subplots
    h{1} = subplot(1,3,1);
    h{1}.PlotBoxAspectRatioMode = 'manual';
    h{1}.PlotBoxAspectRatio = [1 1 1];
    h{1}.DataAspectRatioMode = 'manual';
    h{2} = subplot(1,3,2);
    h{2}.PlotBoxAspectRatioMode = 'manual';
    h{2}.PlotBoxAspectRatio = [1 yHeight 1];
    h{2}.DataAspectRatioMode = 'manual';
    h{3} = subplot(1,3,3);
    h{3}.PlotBoxAspectRatioMode = 'manual';
    h{3}.PlotBoxAspectRatio = [xHeight 1 1];
    h{3}.DataAspectRatioMode = 'manual';

%% Adjust location of main axis
h{1}.Position = [0.1 0.4 0.4 0.4];
MainPos = h{1}.Position;

%% Adjust locations of marginal axes
h{2}.Position = [MainPos(1) MainPos(2)-yMargin-yHeight MainPos(3) yHeight];
h{3}.Position = [MainPos(1)+xMargin+MainPos(3) MainPos(2) xHeight MainPos(4)];

h{3}.XDir = 'reverse';
h{3}.YAxisLocation = 'right';

disp('test')

