function convertFig2PNG(varargin)
%%
%
%
%%

%% Defaults


%% Parse inputs
Parser = inputParser;

addParameter(Parser,'filelist',[])
addParameter(Parser,'fileDirectory',[])
addParameter(Parser,'fileDestination',[])

parse(Parser,varargin{:})

filelist = Parser.Results.filelist;
fileDirectory = Parser.Results.fileDirectory;
fileDestination = Parser.Results.fileDestination;

if isempty(filelist) & isempty(fileDirectory)
    % Find fig files in pwd
    fileDirectory = pwd;
    files = dir('*.fig');
    for filei = 1:length(files)
        filelist{filei} = files(filei).name;
    end
elseif ~isempty(filelist) & ~isempty(fileDirectory)
    warning('Both file list and file directory specified; using file list.')
elseif isempty(filelist)
    % Find .fig files in fileDirectory and make filelist
    files = dir([fileDirectory '/*.fig']);
    for filei = 1:length(files)
        filelist{filei} = files(filei).name;
    end
end

if isempty(fileDestination)
    fileDestination = pwd;
end

%% Go through file list and save output 
for filei = 1:length(filelist)
    fig = openfig([fileDirectory '/' filelist{filei}],'new','invisible');
    saveas(fig,[fileDestination '/' filelist{filei} '.png'],'png')
    close(fig);
end