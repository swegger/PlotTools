function out = ChamberMapGUI2(d,varargin)
%% ChamberMapGUI
%
%   out = ChamberMapGUI(d)
%
%   Graphical user interphase for examining neural data for a project based
%   on location in the chamber.
%
%   Date    Initials    Comment
%   150520  swe         Initial commit
%%

% Defaults

% Parse input
Parser = inputParser;

addRequired(Parser,'d')
addParameter(Parser,'PlotType','Raster')
addParameter(Parser,'CustomParameters',[]);
addParameter(Parser,'ChamberDimensions',[]);
addParameter(Parser,'UserSuppliedObjects',[]);
addParameter(Parser,'SaveLocation','default');

parse(Parser,d,varargin{:})

d = Parser.Results.d;
PlotType = Parser.Results.PlotType;
CustomParameters = Parser.Results.CustomParameters;
ChamberDimensions = Parser.Results.ChamberDimensions;
UserSuppliedObjects = Parser.Results.UserSuppliedObjects;
SaveLocation = Parser.Results.SaveLocation;

% Validate inputs
if strcmp('Custom',PlotType)
    if isempty(CustomParameters)
        error('Custom plot types require custom parameter inputs!')
    end
end

      
%% Initalize variables
UnitsString = {''};
FigureTypesForFile = {'ts v tp'};
FiguresForFile = {''};
axesForFigure = {''};
temphandle = [];
colors = [     0    0.4470    0.7410;...
          0.8500    0.3250    0.0980;...
          0.9290    0.6940    0.1250;...
          0.4940    0.1840    0.5560;...
          0.4660    0.6740    0.1880;...
          0.3010    0.7450    0.9330;...
          0.6350    0.0780    0.1840];

%% Generate GUI

% Set up main figure
h = figure;
h.Units = 'normalized';
h.Position = [0.01 0.01 0.98 0.98];
vbox = uix.VBox( 'Parent', h );
hbox1 = uix.HBox( 'Parent', vbox, 'Padding', 1 );

% Dynamic figure
FigureAx = axes( 'Parent', hbox1, 'Title', 'DummyTitle' );

% Chamber Figure
ChamberAx = axes( 'Parent', hbox1 ,'Title', ['Chamber map for ' d.sname]);
hbox1.Widths = [-1 -1];

% Selection GUI
hbox2 = uix.HBox( 'Parent', vbox, 'Padding', 2 );
fileSelectionBox = uix.BoxPanel( 'Parent', hbox2, 'Title', 'MWorksFile' );
analysisSelectionBox = uix.BoxPanel( 'Parent', hbox2, 'Title', 'Analyses' );
optionsBox = uix.BoxPanel( 'Parent', hbox2, 'Padding', 1, 'Title', 'Analyses Options');
selectMWorksFile = uicontrol('Parent',fileSelectionBox,'Style','listbox','String',d.MWorksFile,'Max',1,'Callback',@fileSelectionCallback);
selectAnalysis = uicontrol('Parent',analysisSelectionBox,'Style', 'listbox','String',AnalysesForFile,'Max',1,'Callback',@analysisCallback);
vbox.Heights = [-2 -1]; 

%% Plot recording sites
axes(ChamberAx)
plot(0,0,'k.','MarkerSize',10)
hold on
for i = 1:length(d.RecordingSite) %d.runs
    if isfield(d,'RecordingSite') && ~isempty(d.RecordingSite{i})
        siteHandles(i) = plot(d.RecordingSite{i}(1),d.RecordingSite{i}(2),'k.');
        ringHandles(i) = plot(d.RecordingSite{i}(1),d.RecordingSite{i}(2),'ko');
        set(ringHandles(i),'Visible','off');
        sites(i,:) = d.RecordingSite{i}(1:2);
        figsOpen(i) = 0;
    else
        siteHandles(i) = plot(NaN,NaN,'k.');
        ringHandles(i) = plot(NaN,NaN,'ko');
        sites(i,:) = [NaN NaN];
        figsOpen(i) = 0;
    end
    
    % Plot the Chamber, if provided
    if ~isempty(ChamberDimensions)
        temp = plot(ChamberDimensions.x,ChamberDimensions.y,'k');
        if isfield(ChamberDimensions,'Properties')
            set(temp,ChamberDimensions.Properties)
        end
    end
    
    % Plot other objects, if provided
    if ~isempty(UserSuppliedObjects)
        for j = 1:length(UserSuppliedObjects)
            temp = plot(UserSuppliedObjects{j}.x,UserSuppliedObjects{j}.y,'k');
            if isfield(UserSuppliedObjects{j},'Properties')
                set(temp,UserSuppliedObjects{j}.Properties)
            end
        end
    end
end
axis equal
xlabel('Medial-lateral (mm)')
ylabel('Anterior-posterior (mm)')
set(gca,'ButtonDownFcn', @mouseclick_callback)
disp('')

%% Callbacks

% Mouse click callback
    function [x,y] = mouseclick_callback(gcbo,eventdata)
        % Get the point clicked
        cP = get(ChamberAx,'Currentpoint');
        x = cP(1,1);
        y = cP(1,2);
        
        % Find the nearest site
        index = find(min((sites(:,1)-x).^2+(sites(:,2)-y).^2) == (sites(:,1)-x).^2+(sites(:,2)-y).^2);
        x = sites(index,1);
        y = sites(index,2);
        
        % Turn on outer ring and set color of dot to be the same color
        colorindex = size(colors,1)+1;
        iter = 0;
        while colorindex > size(colors,1)
            colorindex = index - iter*size(colors,1);
            iter = iter+1;
        end
        for i = 1:length(siteHandles)
            if i == index
                siteHandles(i).Color = colors(colorindex,:);
                ringHandles(i).Visible = 'on';
                ringHandles(i).Color = colors(colorindex,:);
            else
                siteHandles(i).Color = [0 0 0];
                ringHandles(i).Visible = 'off';
                ringHandles(i).Color = [0 0 0];
            end
        end
        
        % Select new MWorks file
        selectMWorksFile.Value = index;
        
        % Generate list of units
        totalunits = length(d.spikes{index}{1});
        for i = 1:totalunits
            UnitsString{i} = num2str(i);
        end
        selectUnit.String = UnitsString;
        
    end % End of mouseclick callback


% File selection callback
    function fileSelected = fileSelectionCallback(gcbo,eventdata)
        % Get the index of the file selected
        index = selectMWorksFile.Value;
        
        % Turn on outer ring and set color of dot to be the same color
        for i = 1:length(d.RecordingSite) %d.runs
            if any(index == i)
                colorindex = size(colors,1)+1;
                iter = 0;
                while any(colorindex > size(colors,1))
                    colorindex = index - iter*size(colors,1);
                    iter = iter+1;
                end
                siteHandles(i).Color = colors(colorindex,:);
                ringHandles(i).Visible = 'on';
                ringHandles(i).Color = colors(colorindex,:);
                
            else
                siteHandles(i).Color = [0 0 0];
                ringHandles(i).Visible = 'off';
                ringHandles(i).Color = [0 0 0];
            end
        end
        
        fileSelected = d.MWorksFile{selectMWorksFile.Value};
        
        % Generate list of analyses
        selectAnalysis.String = d.Analyses{selectMWorksFile.Value}.Types;
    end


% Analysis selection callback
    function analysisType = analysisCallback(gcbo,eventdata)
        % Generate temporary vboxes
        tempvbox{1} = uix.VBox( 'Parent', optionsBox, 'Padding', 2, 'Title', 'Units' );
        for i = 2:length(d.Analyses{selectMWorksFile.Value}.Options)+1
            tempvbox{i} = uix.Vbox( 'Parent', optionsBox, 'Padding', 2);
        end
        tempvbox{length(d.Analyses{selectMWorksFile.Value}.Options)+2} = uix.Vbox('Parent',optionsBox,'Padding',2);
        
        % Generate unit selection callback
        if isempty(d.spikes{index})
            UnitsString{1} = 'None';
        else
            totalunits = length(d.spikes{index}{1});
            for i = 1:totalunits
                UnitsString{i} = num2str(i);
            end
        end
        selectUnit = uicontrol('Parent',tempvbox{1},'Style', 'listbox','String',UnitsString,'Max',1,'Callback',@analysisCallback);
        
        % Generate options callbacks
        for i = 1:length(d.Analyses{selectMWorksFile.Value}.Options)
            str = d.Figures{selectMWorksFile.Value}.Files{selectUnit.Value}{selectFigureType.Value}{i};
            startind = regexp(str,['[A-Z_a-z]{1,5}[1,2]?' selectFigureType.String{selectFigureType.Value}]);
            FiguresForFile{i} = d.Figures{selectMWorksFile.Value}.Files{selectUnit.Value}{selectFigureType.Value}{i}(startind:end);
        end
        %FiguresForFile = d.Figures{selectMWorksFile.Value}.Files{selectUnit.Value}{selectFigureType.Value};
        selectFigure.String = FiguresForFile;
    end




%% Set output on close of window
disp('Close GUI to continue...')
waitfor(h)
close(temphandle)
out = [];

end % End of ChamberMapGUI