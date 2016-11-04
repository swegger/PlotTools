function patchHandle = myPatch(x,y,w,varargin)
%% myPatch
%
%   patchHandle = myPatch(x,y,w)
%       Creates and plots a patch obeject for every column of X that
%       follows the path (x,y) with width w.
%
%   patchHandle = myPatch(...,'patchProperties',patchProperties)
%       Plots the patch according to the obect properties in
%       patchProperties.
%  
% swe
%% 

%% Defaults


%% Parse inputs
Parser = inputParser;

addRequired(Parser,'x')
addRequired(Parser,'y')
addRequired(Parser,'w')
addParameter(Parser,'axesHandle',gca)
addParameter(Parser,'patchProperties',NaN)

parse(Parser,x,y,w,varargin{:});

x = Parser.Results.x;
y = Parser.Results.y;
w = Parser.Results.w;
axesHandle = Parser.Results.axesHandle;
patchProperties = Parser.Results.patchProperties;

%% Patch properties
if iscell(patchProperties)
    if length(patchProperties) == size(x,2)
        for i = 1:length(patchProperties)
            patchProps{i} = SetPatchProperties(patchProperties{i});
        end
    else
        error('patchProperties cell must equal size(x,2)')
    end
elseif isstruct(patchProperties)
    for i = 1:size(x,2)
        patchProps{i} = SetPatchProperties(patchProperties);
    end
elseif isnan(patchProperties)
    for i = 1:size(x,2)
        patchProps{i} = createPatchDefaults();
    end
end



%% Create patch vectors
if isempty(w)
   xpatch = [x; flipud(x)];
   ypatch = [zeros(size(x)); flipud(y)];
else
    xpatch = [x; flipud(x)];
    ypatch = [y - w; flipud(y + w)];
end

%% Plot the objects
% Create objects
for i = 1:size(x,2)
    patchHandle{i} = patch(xpatch(:,i),ypatch(:,i),'k');
    hold on
end

% Set properties
for i = 1:length(patchHandle)
    set(patchHandle{i},patchProps{i})
end


%% Functions
% Set patch Properties
function propsOut = SetPatchProperties(propsIn)
    propsOut = createPatchDefaults();
    names = fieldnames(propsIn);
    for namei = 1:length(names)
        propsOut = setfield(propsOut,names{namei},getfield(propsIn,names{namei}));
    end


% Create Default patch object;
function patchDefaults = createPatchDefaults()
patchDefaults.AlignVertexCenters =  'off';
patchDefaults.AlphaDataMapping = 'scaled';
patchDefaults.AmbientStrength = 0.3000;
patchDefaults.BackFaceLighting = 'reverselit';
patchDefaults.CData = [];
patchDefaults.CDataMapping = 'scaled';
patchDefaults.Children = [];
patchDefaults.Clipping = 'on';
patchDefaults.CreateFcn = '';
patchDefaults.DeleteFcn = '';
patchDefaults.DiffuseStrength = 0.6000 ;
patchDefaults.DisplayName = '';
patchDefaults.EdgeAlpha = 1 ;
patchDefaults.EdgeColor = 'none';
patchDefaults.EdgeLighting = 'none';
patchDefaults.FaceAlpha = 1 ;
patchDefaults.FaceColor = [0.7 0.7 0.7];
patchDefaults.FaceLighting = 'flat';
patchDefaults.FaceNormals = [];
patchDefaults.FaceNormalsMode = 'auto';
patchDefaults.FaceVertexAlphaData = [];
patchDefaults.FaceVertexCData = [];
patchDefaults.HandleVisibility = 'on';
patchDefaults.HitTest = 'on';
patchDefaults.Interruptible = 'on';
patchDefaults.LineStyle = '-';
patchDefaults.LineWidth = 0.5000 ;
patchDefaults.Marker = 'none';
patchDefaults.MarkerEdgeColor = 'auto';
patchDefaults.MarkerFaceColor = 'none';
patchDefaults.MarkerSize = 6 ;
patchDefaults.PickableParts = 'visible';
patchDefaults.Selected = 'off';
patchDefaults.SelectionHighlight = 'on';
patchDefaults.SpecularColorReflectance = 1 ;
patchDefaults.SpecularExponent = 10 ;
patchDefaults.SpecularStrength = 0.9000 ;
patchDefaults.Tag = '';
patchDefaults.VertexNormalsMode = 'auto';
patchDefaults.Visible = 'on';