% makeaxis.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to make phyplot like axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      usage: makeaxis.m()
%         by: mehrdad jazayeri
%       date: Oct 2006
%
function mymakeaxis(ax, varargin)

if nargin==0
	ax = gca;
	argin = {};
elseif ~mod(nargin,2)
	argin = {ax, varargin{:}};
	ax = gca;
else
	axes(ax);
	argin = varargin;
end

eval(evalargs(argin));

if ~exist('majorTickRatio'), majorTickRatio = 0.02;, end
if ~exist('minorTickRatio'), minorTickRatio = 0.01/2;, end
if ~exist('offsetRatio'), offsetRatio = 0.05;, end
if ~exist('x_label'), x_label=ax.XLabel.String;, end
if ~exist('y_label'), y_label=ax.YLabel.String;, end
if ~exist('xytitle'), xytitle=ax.Title.String;, end
if ~exist('xticks'), xticks=ax.XTick; end
if ~exist('yticks'), yticks=ax.YTick; end
if ~exist('xticklabels'), xticklabels=ax.XTickLabel; end
if ~exist('yticklabels'), yticklabels=ax.YTickLabel; end
if ~exist('xaxisOn'), xaxisOn = true; end
if ~exist('yaxisOn'), yaxisOn = true; end

if ~exist('font_name'), font_name = 'helvetica';, end
if ~exist('font_size'), font_size = 16;, end
if ~exist('font_angle'), font_angle = 'italic';, end
if ~exist('interpreter'), interpreter = 'tex'; end

% turn off current axis
%axis tight;
axis off;
hold on;
% get the current x and y limits
xlims = xlim;
ylims = ylim;

% % get the current x and y tick positions
% xticks = get(ax,'XTick');
% yticks = get(ax,'YTick');
% 
% % get the current x and y tick labels
% xticklabels = get(ax,'XTickLabel');
% yticklabels = get(ax,'YTickLabel');

% get the current x and y labels
xaxis.label = x_label;
yaxis.label = y_label;
% get the current axis title
xaxis.xytitle = xytitle;

% set majotTickLen
xaxis.majorTickLen = majorTickRatio*(ylims(2)-ylims(1));
yaxis.majorTickLen = majorTickRatio*(xlims(2)-xlims(1));

% set minorTickLen
xaxis.minorTickLen = minorTickRatio*(ylims(2)-ylims(1));
yaxis.minorTickLen = minorTickRatio*(xlims(2)-xlims(1));

% set offset
xaxis.offset = offsetRatio*(ylims(2)-ylims(1));
yaxis.offset = offsetRatio*(xlims(2)-xlims(1));

axis([xlims ylims]+[-yaxis.offset-20*yaxis.majorTickLen 0 -xaxis.offset-20*xaxis.majorTickLen 0]);

% draw horizontal axis lines 
if xaxisOn
    plot(xlims,[ylims(1)-xaxis.offset ylims(1)-xaxis.offset],'k');
    
    % draw major tick on horizontal axis with approporiate labels
    for i = xticks
        thisticklabel = xticklabels{find(xticks==i)};
        % draw major tick
        plot([i i],[ylims(1)-xaxis.offset ylims(1)-xaxis.majorTickLen-xaxis.offset],'k');
        % put label
        thandle = text(i,ylims(1)-xaxis.offset-1.5*xaxis.majorTickLen,thisticklabel);
        %  get(thandle)
        % and format the text
        set(thandle,'HorizontalAlignment','center');
        set(thandle,'VerticalAlignment','top');
        set(thandle,'FontSize',font_size);
        set(thandle,'FontName',font_name);
        set(thandle,'FontAngle',font_angle);
    end
end

% draw vertical axis lines 
if yaxisOn
    plot([xlims(1)-yaxis.offset xlims(1)-yaxis.offset],ylims,'k');hold on
    
    % draw major tick on horizontal axis with approporiate labels
    for i = yticks
        thisticklabel = yticklabels{find(yticks==i)};
        % draw major tick
        plot([xlims(1)-yaxis.offset xlims(1)-yaxis.offset-yaxis.majorTickLen],[i i],'k');
        % draw text
        thandle = text(xlims(1)-yaxis.offset-2*yaxis.majorTickLen,i,thisticklabel);
        % and format the text
        set(thandle,'HorizontalAlignment','right');
        set(thandle,'VerticalAlignment','middle');
        set(thandle,'FontSize',font_size);
        set(thandle,'FontName',font_name);
        set(thandle,'FontAngle',font_angle);
    end
end

% add x axis label
thandle = text(mean(xlims(:)),ylims(1)-xaxis.offset-15*xaxis.majorTickLen,xaxis.label,'interpreter',interpreter);
set(thandle,'HorizontalAlignment','center');
set(thandle,'VerticalAlignment','top');
set(thandle,'FontSize',font_size);
set(thandle,'FontName',font_name);
set(thandle,'FontAngle',font_angle);
  
% add y axis label
thandle = text(xlims(1)-yaxis.offset-15*yaxis.majorTickLen,mean(ylims(:)),yaxis.label,'interpreter',interpreter);
set(thandle,'HorizontalAlignment','center');
set(thandle,'VerticalAlignment','bottom');
set(thandle,'FontSize',font_size);
set(thandle,'FontName',font_name);
set(thandle,'FontAngle',font_angle);
set(thandle,'Rotation',90);

% add title
thandle = text(mean(xlims(:)),ylims(2)+0.05*(ylims(2)-ylims(1)),xaxis.xytitle,'interpreter',interpreter);
set(thandle,'HorizontalAlignment','center');
set(thandle,'VerticalAlignment','bottom');
set(thandle,'FontSize',font_size);
set(thandle,'FontName',font_name);
set(thandle,'FontAngle',font_angle);


% evalargs.m
%
%      usage: evalargs(args)
%         by: mehrdad jazayeri
%       date: May 2006
%    purpose: passed in varargin, returns a string
%             that once evaluated sets the variables
%             called for.
%             The varargin must be in pairs, where
%             the first specifies the name of the variable
%             and the 2nd the value.
%             The value can take many forms:
%               1. numerical: e.g. 4 or [4 5 6]
%               2. string: 'whatever'
%               3. cell array of strings: {'s1' 's2' 's3'}
%               4. cell array of numbers {1 [2 3] 5}
%
%				Also the first arg can be a structure, in which case varargin can be 2K+1
%				In this case, the field names and their corresponding values would also 
%				be added to the rest of args
%				for instance: S.x = 1; S.y='a'; 
%				then 
%				evalargs({S, 'test', 1})
%				would be the same as
%				evalargs({'x', 1, 'y', 'a', 'test', 1});
%				
%             usage:  
%             start the body of your desired function function fun(varargin)
%             with the line:  eval(evalargs(varargin));
%             example:
%             func('name1',4,'name2',[4 5],'name3','string1','name4',{'string2' 'string3'},'name5',{4 [3 3]})
%

function evalstr = evalargs(args)

evalstr='';

if mod(length(args),2)
	if isstruct(args{1})
		fromstruct = [fieldnames(args{1}) struct2cell(args{1})]';
		args = [fromstruct(:)' args{2:end}];
	else
	    help evalargs;
    	display('variables/values are not in pairs!');
    	display('will attempt to assign those in pairs. press any key to continue..');
    	args = args(1:end-1);
    	pause;
	end
end

for i = 1:2:length(args)
    % dealing with errors; var names must be strings
    if ~isstr(args{i})
        help evalargs;
        return
    else
        varName = args{i};
    end
    varVal = args{i+1};
    % dealing with cell arrays
    if iscell(varVal)
        cellVal = args{i+1};
        % dealing with cell array of strings
        if isstr(cellVal{1})
            xx = sprintf('''%s''',cellVal{1});
            for j = 2:length(cellVal)
	        	if isstr(cellVal{j})
					xx = sprintf('%s,''%s''',xx,cellVal{j});
				else
                	xx = sprintf('%s,[%s]',xx,num2str(cellVal{j}));
			    end 
            end
            xx = ['{' xx '}'];
            assignment = sprintf('%s=%s;',varName, xx);
            evalstr = sprintf('%s%s',evalstr,assignment);
        % dealing with cell array of number vectors
        else
            xx = sprintf('[%s]',num2str(cellVal{1}));
            for j = 2:length(cellVal)
                xx = sprintf('%s,[%s]',xx,num2str(cellVal{j}));
            end
            xx = ['{' xx '}'];
            assignment = sprintf('%s=%s;',varName, xx);
            evalstr = sprintf('%s%s',evalstr,assignment);
        end
    % dealing with strings
    elseif isstr(varVal)
        strVal = args{i+1};
        assignment = sprintf('%s=''%s'';',varName, strVal);
        evalstr = sprintf('%s%s',evalstr,assignment);
    %dealing with number vectors    
    else
        numVal = args{i+1};
        assignment = sprintf('%s=[%s];',varName, num2str(numVal));
        evalstr = sprintf('%s%s',evalstr,assignment);
    end
%    display(sprintf('%s',assignment));
end