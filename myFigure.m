function h = myFigure(varargin)
%% myFigure
%
%   h = myFigure;
%   Generates a new figure with default prefrences. Returns a handle to
%   that figure, h.
%
%   h = myFigure('figureProperties',figureProperties);
%   Generates a new figure with the properties specified by
%   figureProperties.
%
%%

%% Defaults
figureProperties_default.Units = 'normalized';
figureProperties_default.Color = [1 1 1];

%% Parse inputs
Parser = inputParser;

addParameter(Parser,'figureProperties',figureProperties_default)

parse(Parser,varargin{:});

figureProperties = Parser.Results.figureProperties;

%% Generate figure
h = figure;
set(h,figureProperties);