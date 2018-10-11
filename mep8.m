function [codeFix,issues] = mep8(fileName,cfg,overwrite)
% Checks style issues in matlab code, fixes and overwrites if requested.
%% Input - output
%  - fileName is a *.m text file with code to check / fix
%  - overwrite (optional) is true or false. when true, fileName is overwritten and a
% backup file is created, ending in bkp.m
%  - cfg (optional) is a struct with configuration fields. see cfg options below
%  - codeFix is a string containing fixed code
%  - issues contain fields describing the different issues encountered line
% by line.
%% features:
%  - use checkcode.m to report code errors etc. chsckcode issues are reported
% but not fixed.
%  - use indentcode.m to check and fix indentation issues.
%  - use splitcode (adapted from m2html) to process the text. This labels
% strings and comments in the code, not to be touched when fixing (see
% splitCode below).
%  - pad "=" with spaces, or any char defined in spacePad variable
%% cfg options
%  - cfg.factory = true (default) tells chekccode to ignore warning supression
% previously defined by the user (e.g. %#ok comments inline). If you set
% cfg.factory to false it may not be mep8 style anymore, but this is
% freedom for you.
%  - cfg.okayIssue is an N by 1 cell array with strings indicating that some issues
%  are to be ignored. The default is to ignore Matlab messages about
%  variables changing size in a loop: cfg.okayIssue{1,1} = 'appears to change size';
%% To Do
%  - polish and test on more code
%  - decide what to do with * / .^ etc
%  - treat function names, mainly bad style e.g Func_Name
%  - do something about line lengths
%  - check scope of short varNames
%  - offer iStart for istart and starti
%  - treat comments: capital 1st letter, function statment last comment,
%  space after %, empty line after last informative comment
%  - accept directory, perhaps also recursively
%% website
% See author, license and more stuff here https://yuval-harpaz.github.io/mep8/
% (click view on github)
% [codeFix,issues] = mep8(fileName,cfg,overwrite)


%% Assign default values
% when no fileName is given (no such var or empty) take default test file
fileName = defaultVal('fileName',[fileparts(which('mep8.m')),'/tests/test1.m']);
if ~isequal(fileName(end-1:end),'.m')
    tmp = which(fileName);
    if ~isempty(tmp)
        fileName = tmp;
    end
end
if ~exist(fileName,'file')
    error([fileName,' not found'])
end
overwrite = defaultVal('overwrite',false); % overwrite file and save backup?
spacePad = '><=|&'; % which stuff to pad with spaces
noSpaceNear = '~><=|&'; % between which chars not to isert space, e.g. ~=   &&
cfg = defaultVal('cfg',struct);
if ~isfield(cfg,'okayIssue')
    cfg.okayIssue{1,1} = 'appears to change size'; % okay with mep8 to change size of a variable within a loop
end
if ~isfield(cfg,'factory')
    cfg.factory = true; % okay with mep8 to change size of a variable within a loop
end
%% check compatibility / code warnings
disp('running checkcode: ')
if cfg.factory
    issuesCodecheck = checkcode(fileName,'-string','-config=factory');
else
    issuesCodecheck = checkcode(fileName,'-string');
end
if ~isempty(issuesCodecheck)
    if isfield(cfg,'okayIssue')
        for iOkay = 1:length(cfg.okayIssue)
            deleteMessage = strfind(issuesCodecheck,cfg.okayIssue{iOkay});
            if ~isempty(deleteMessage)
                rmLoc = false(1,length(issuesCodecheck));
                for iMsg = 1:length(deleteMessage)
                    nlLoc = find(ismember(issuesCodecheck,newline));
                    % next newline
                    nl1 = nlLoc(find(nlLoc > deleteMessage(iMsg),1));
                    % previous newline
                    nl0 = nlLoc(find(nlLoc < deleteMessage(iMsg),1,'last'));
                    if isempty(nl0)
                        rmLoc(1:nl1) = true;
                    else
                        rmLoc(nl0+1:nl1) = true;
                    end
                end
                issuesCodecheck(rmLoc) = [];
            end
        end
    end
end
% process code to find variable names etc
% see http://undocumentedmatlab.com/blog/parsing-mlint-code-analyzer-output

if isempty(issuesCodecheck)
    fprintf('\b no issues\n\n')
else
    disp(issuesCodecheck);
end
issues.codeCheck = issuesCodecheck;
%% read text file
fr = fopen(fileName);
codeOrig = native2unicode(fread(fr,'uint8=>uint8')');
fclose(fr);
% replace return \r with newline \n
codeOrig = regexprep(codeOrig, '\r\n?', '\n');
% make sure last character is newline
if ~isequal(codeOrig(end),newline)
    codeOrig(end+1) = newline;
end

%% use matlab automatic indentation to add / remove spaces
disp('checking bad indentation:')
codeFix = indentcode(codeOrig);
% find newline location in orig (0) and new text (1)
newLines0 = regexp(codeOrig,'\n');
newLines1 = regexp(codeFix,'\n');
if ~isequal(length(newLines0),length(newLines1))
    error('indented code and orig have different numbers of lines');
end
%location of line beginning in texts
startLine0 = [1,newLines0(1:end-1)+1];
startLine1 = [1,newLines1(1:end-1)+1];
% go line by line and check differences in spaces location
% along the way, process codeFix and label the contents
%
content = repmat('c',1,length(codeFix)); % c  is for code (not cookey)
codeFixRow = nan(size(codeFix));
content(strfind(codeFix,newline)) = 'n';
issuesIndent = '';
for linei = 1:length(startLine0)
    line0 = codeOrig(startLine0(linei):newLines0(linei)-1);
    line1 = codeFix(startLine1(linei):newLines1(linei)-1);
    spaceMessage = '';
    linStr = num2str(linei);
    spaceIdx0 = ismember(line0,' ');
    spaceIdx1 = ismember(line1,' ');
    % check length of indentation
    if isempty(line0)
        indent0 = 0;
    else
        indent0 = find(~spaceIdx0,1);
    end
    indent1 = find(~spaceIdx1,1);
    
    if isempty(indent1) && any(spaceIdx1) % a codeFix line with nothing but spaces
        indent1 = sum(spaceIdx1);
        content(startLine1(linei):startLine1(linei)+length(line1)-1) = 'i';
    elseif indent1 > 1 % a line with spaces and then something else
        content(startLine1(linei):startLine1(linei)+indent1-2) = 'i';
    end
    codeFixRow(startLine1(linei):newLines1(linei)) = linei;
    % split to look for strings and comments (from m2html)
    splitc = splitCode(line1);
    start = startLine1(linei); % marks beginning of split strings
    for spliti = 1:length(splitc)
        if ~isempty(splitc{spliti})
            switch splitc{spliti}(1)
                case '%'
                    content(start:start+length(splitc{spliti})-1) = '%';
                case ''''
                    content(start:start+length(splitc{spliti})-1) = '''';
            end
        end
        start = start+length(splitc{spliti}); % location of next split
    end
    
    if ~strcmp(line0,line1)
        if indent1 > indent0
            num = num2str(indent1-indent0);
            spaceMessage = ['Add ',num,' spaces. '];
        elseif indent1 < indent0
            num = num2str(indent0-indent1);
            spaceMessage = ['remove ',num,' spaces. '];
        end
        if sum(~spaceIdx0) == sum(~spaceIdx1)
            lastNotSpace0 = find(~spaceIdx0,1,'last');
            lastNotSpace1 = find(~spaceIdx1,1,'last');
            if lastNotSpace1 < length(line1)
                error('last fixed charecter should not be space')
            end
            if isempty(lastNotSpace0)
                lastNotSpace0 = 0; % only spaces in a line
            end
            if lastNotSpace0 < length(line0)
                spaceMessage = [spaceMessage,num2str(length(line0)-lastNotSpace0),...
                    ' extra spaces in end of line'];
            end
        end
        addMessage = true;
        if isfield(cfg,'okayIssue')
            for iOkay = 1:length(cfg.okayIssue)
                okayInMsg = strfind(spaceMessage,cfg.okayIssue{iOkay});
                if ~isempty(okayInMsg)
                    addMessage = false;
                end
            end
        end
        if addMessage
            issuesIndent = [issuesIndent,'L ',linStr,': ',spaceMessage,newline];
        end
    end
end
if isempty(issuesIndent)
    fprintf('\b no issues \n\n')
else
    disp(issuesIndent)
end
issues.indent = issuesIndent;

%% look for '=' or other stuff to pad with spaces
disp(['padding ',spacePad,' with spaces: '])
issuesSpace = '';
doPadding = true;
if isfield(cfg,'okayIssue')
    for iOkay = 1:length(cfg.okayIssue)
        okayInMsg = strfind(' padded with spaces.',cfg.okayIssue{iOkay});
        if ~isempty(okayInMsg)
            doPadding = false;
            fprintf('\b skipping because of cfg.okayIssue \n\n')
        end
    end
end
if doPadding
    
    toPad = ismember(codeFix,spacePad);
    insertSpace = toPad; % make space after "="
    insertSpace(find(toPad)-1) = true; % make space before "="
    % find ~= <= and >=
    logi = find(ismember(codeFix,noSpaceNear));
    if ~isempty(logi)
        %spacei = find(insertSpace);
        [~,ii] = ismember(logi,find(toPad)-1);
        if any(ii)
            logi = logi(ii > 0);
            insertSpace(logi) = false;
            insertSpace(logi-1) = true;
        end
    end
    insertSpace(ismember(codeFix,' ')) = false; % dont insert space after space
    insertSpace(find(ismember(codeFix,' '))-1) = false;  % dont insert space before space
    % avoid analyzing strings and comments
    insertSpace(ismember(content,'%')) = false;
    insertSpace(ismember(content,'''')) = false;
    if sum(insertSpace) > 0
        if isfield(cfg,'dbg')
            tmp1 = 'code                                               ';
            tmp1(2,:) = 'insert space after                                 ';
            tmp1(3,:) = ['c=code, %=comment, i=indent, ''','=string, n=newline   '];
            tmp2 = strrep(num2str(insertSpace),' ','');
            tmp2 = strrep(tmp2,'0','_');
            tmp2 = strrep(tmp2,'1','^');
            tmp3 = [strrep(codeFix,newline,'N');tmp2;content];
            disp('location of "insert space after"');
            disp([tmp1,tmp3]);
        end
        if ~isempty(unique(content(insertSpace))) && ~isequal(unique(content(insertSpace)),'c')
            error('space insertion not in code "c"')
        end
        spacedLines = unique(codeFixRow(insertSpace));
        for linei = 1:length(spacedLines)
            loc = find(insertSpace & codeFixRow == spacedLines(linei));
            padded = spacePad(ismember(spacePad,codeFix(loc(1)-1:loc(end))));
            issuesSpace = [issuesSpace,'L ',num2str(spacedLines(linei)),': ',...
                padded,' padded with spaces.',newline];
        end
        disp(issuesSpace)
        % Here we actually do the space padding
        for inserti = sort(find(insertSpace),'descend')
            codeFix = insertAfter(codeFix,inserti,' ');
            content = insertAfter(content,inserti,'c');
        end
    else
        fprintf('\b no issues\n\n')
    end
end
issues.spacePad = issuesSpace;

%% variable names
disp('checking variable names:')
issuesVarNames = '';
cCodeEdit = checkcode(fileName,'-edit'); % -ty gives variable lines
if isempty(cCodeEdit)
    fprintf('\b no variables found\n\n')
else
    cCodeEdit = cCodeEdit(1).message;
    varLines = regexp(cCodeEdit,newline,'split')';
    varLines = varLines(contains(varLines,' V '));
    cCodeTY = checkcode(fileName,'-ty');
    cCodeTY = cCodeTY(1).message;
    if isempty(varLines)
        fprintf('\b no variables found\n\n')
    else
        % get variable names from text
        spaceLims = find(diff(ismember(varLines{1},' ')) > 0,2)+1;
        varNames = cellfun(@(x) strrep(x(spaceLims(1):spaceLims(2)),' ',''),...
            varLines, 'UniformOutput',false);
        varNames = unique(varNames);
        startWithUpper = cellfun(@(x) isequal(x(1),upper(x(1))),varNames);
        if any(startWithUpper)
            for iUpper1 = find(startWithUpper)'
                %tmp4 = join(varNames(startWithUpper)');
                issuesVarNames = [issuesVarNames,...
                    'L ',varL(varNames{iUpper1},cCodeTY),': Variable ',varNames{iUpper1},...
                    ' starts with an uppercase letter',newline];
            end
        end
        % check scope of short name variables
        varLength = cellfun(@(x) length(x),varNames);
        for len = 1:4
            varsToCheck = find(varLength == len);
            if ~isempty(varsToCheck)
                for iVar = 1:length(varsToCheck)
                    [line1str,allLines] = varL(varNames(varsToCheck(iVar)),cCodeTY);
                    scope = range(allLines)+1;
                    % here we allow scope to be 15 lines * name length
                    if scope > len*15
                        issuesVarNames = [issuesVarNames,'L ',line1str,...
                            ': ',varNames{varsToCheck(iVar)},' has a scope of ',...
                            num2str(scope),' lines. Name length should be at least ',...
                            num2str(min(ceil(scope/15),6)),' chars long',newline];
                    end
                end
                
            end
        end
        % look for two words such as finaltest
        if exist('words4mep8.mat','file')
            load words4mep8 words
        else
            try
                words = urlread('https://raw.githubusercontent.com/first20hours/google-10000-english/master/google-10000-english.txt');
                words = regexp(words,newline,'split')';
                exclude = cellfun(@(x) length(x),words) < 2; % single letters are not words
                exclude(123+find(cellfun(@(x) length(x),words(124:end)) == 2)) = true; % two letters (infrequent, below 130) are not words
                words(exclude) = [];
            catch
                disp('words list requires internet connection')
            end
        end
        if exist('words','var')
            for vari = 1:length(varNames)
                if length(varNames{vari}) > 5 % dont try to combine two words if the name is short
                    if ~ismember(varNames{vari},words) ... % variable name is not a word
                            && ~contains(varNames{vari},'_') ... % no underscore
                            && isequal(varNames{vari},lower(varNames{vari})) % no upper-case letters
                        for cutPoint = 3:length(varNames{vari})-2
                            w1 = ismember(lower(varNames{vari}(1:cutPoint)),words);
                            w2 = ismember(lower(varNames{vari}(cutPoint+1:end)),words);
                            if w1 && w2
                                optionCap = [lower(varNames{vari}(1:cutPoint)),...
                                    upper(varNames{vari}(cutPoint+1)),lower(varNames{vari}(cutPoint+2:end))];
                                if ~isequal(varNames{vari},optionCap)
                                    var1stLine = varL(varNames{vari},cCodeTY);
                                    issuesVarNames = [issuesVarNames,['L ',var1stLine,...
                                        ': Consider renaming ',varNames{vari},' as ',optionCap,newline]];
                                end
                            end
                        end
                    end
                end
            end
        else
            warning('unable to get a list of words to check variable names for wordness')
        end
        % see that variable names do not shadow existing functions
        for vari = 1:length(varNames)
            otherUses = existDict(varNames{vari});
            if ~isempty(otherUses)
                issuesVarNames = [issuesVarNames,'L ',varL(varNames{vari},cCodeTY),': Variable ',otherUses,newline];
            end
        end
    end
    % sort the messages by line number
    if isempty(issuesVarNames)
        fprintf('\b no issues\n\n')
    else
        issuesVarNames = regexp(issuesVarNames(1:end-1),newline,'split');
        lNum = cell2mat(cellfun(@(x) str2double(x(3:strfind(x,':')-1)),...
            issuesVarNames,'UniformOutput',false));
        [~,order] = sort(lNum);
        issuesVarNames = issuesVarNames(order);
        issuesVarNames = join([issuesVarNames',repmat({newline},length(issuesVarNames),1)]);
        issuesVarNames = join(issuesVarNames);
        issuesVarNames = issuesVarNames{1};
        issuesVarNames = strrep(issuesVarNames,[newline,' L'],[newline,'L']);
        disp(issuesVarNames);
    end
end
issues.varNames = issuesVarNames;
%% line length 80?


%% overwrite if requested, save backup ('*bkp.m')
if overwrite && ~isequal(codeFix,codeOrig)
    [pat1,pat2,pat3] = fileparts(fileName);
    if ~isempty(pat1)
        pat1 = [pat1,'/'];
    end
    bkpNew = false;
    jj = 0;
    while bkpNew == false
        jj = jj+1;
        backup = [pat1,pat2,'_',num2str(jj),'bkp',pat3];
        if ~exist(backup,'file')
            bkpNew = true;
            
            fbkp = fopen(backup,'w');
            fwrite(fbkp,codeFix);
            fclose(fbkp);
            if ~exist(backup,'file')
                error('backup file not created, not overwriting')
            end
            fw = fopen(fileName,'w');
            fwrite(fw,codeFix);
            fclose(fw);
            disp(['overwrote, backup file: ',backup])
        end
    end
end

%% Internal functions
function val = defaultVal(varName,defValue)
% assigns defValue to varName when varName does not exist or empty
if evalin('caller',['exist(''',varName,''',','''var''',');'])
    val = evalin('caller',varName);
else
    val = [];
end
if isempty(val)
    val = defValue;
end

function splitc = splitCode(code2split)
% adapted from m2html
% splits line of Matlab code CODE into a cell
%  array SPLITC where each element is either a character array ('...'),
%  a comment (%...), a continuation (...) or something else.
%  Note that CODE = [SPLITC{:}]
%
%  See also M2HTML, HIGHLIGHT
%  GNU 2.0 license or later
%  Copyright (C) 2003 Guillaume Flandin <Guillaume@artefact.tk>
%  $Revision: 1.0 $Date: 2003/29/04 17:33:43 $

%- Label quotes in {'transpose', 'beginstring', 'midstring', 'endstring'}
iquote = strfind(code2split,'''');
quotetransp = [double('_''.)}]') ...
    double('A'):double('Z') ...
    double('0'):double('9') ...
    double('a'):double('z')];
flagString = 0;
flagdoublequote = 0;
jquote = [];
for iq = 1:length(iquote)
    if ~flagString
        if iquote(iq) > 1 && any(quotetransp == double(code2split(iquote(iq)-1)))
            % => 'transpose';
        else
            % => 'beginstring';
            jquote(size(jquote,1)+1,:) = [iquote(iq) length(code2split)];
            flagString = 1;
        end
    else % if flagstring
        if flagdoublequote || ...
                (iquote(iq) < length(code2split) && strcmp(code2split(iquote(iq)+1),''''))
            % => 'midstring';
            flagdoublequote = ~flagdoublequote;
        else
            % => 'endstring';
            jquote(size(jquote,1),2) = iquote(iq);
            flagString = 0;
        end
    end
end

%- Find if a portion of code is a comment
ipercent = strfind(code2split,'%');
jpercent = [];
for ip = 1:length(ipercent)
    if isempty(jquote) || ...
            ~any((ipercent(ip) > jquote(:,1)) & (ipercent(ip) < jquote(:,2)))
        jpercent = [ipercent(ip) length(code2split)];
        break;
    end
end

%- Remove strings inside comments
if ~isempty(jpercent) && ~isempty(jquote)
    jquote(jquote(:,1) > jpercent(1),:) = [];
end

%- Split code in a cell array of strings
icode = [jquote ; jpercent];
splitc = {};
if isempty(icode)
    splitc{1} = code2split;
elseif icode(1,1) > 1
    splitc{1} = code2split(1:icode(1,1)-1);
end
for ic = 1:size(icode,1)
    splitc{end+1} = code2split(icode(ic,1):icode(ic,2));
    if ic < size(icode,1) && icode(ic+1,1) > icode(ic,2) + 1
        splitc{end+1} = code2split((icode(ic,2)+1):(icode(ic+1,1)-1));
    elseif ic == size(icode,1) && icode(ic,2) < length(code2split)
        splitc{end+1} = code2split(icode(ic,2)+1:end);
    end
end
function str = existDict(var4existDict)
% check what sort of thing is var4existDict
existNum = exist(var4existDict); %#ok<EXIST>
str = '';
switch existNum
    case 0
        str = ''; %if NAME does not exist
    case 1
        str = ''; % NAME is a variable in the workspace
    case 2
        str = [var4existDict,' is a file with extension .m, .mlx, or .mlapp, .mat, .fig, or .txt)'];
    case 3
        str = [var4existDict,' is a MEX-file on the MATLAB search path'];
    case 4
        str = [var4existDict,' is a Simulink model or library file on the MATLAB search path'];
    case 5
        str = [var4existDict,' is a built-in MATLAB function'];
    case 6
        str = [var4existDict,' is a P-code file on the MATLAB search path'];
    case 7
        str = ''; % a folder
    case 8
        str = [var4existDict,' is a class'];
end

function [line1str,allLines] = varL(vName,ccTYf)
% Returns the first appearance of a variable (line number) as a string
% If requested, returns all appearances in the code.
if nargout == 1 % quickly check first instance of a variable
    varInTY = strfind(ccTYf,[newline,vName,':']);
    varInTY = varInTY(1);
    var1stLine = regexp(ccTYf(varInTY:end),'\d*','match');
    line1str = var1stLine{1};
elseif nargout == 2
    ccTYlines = regexp(ccTYf,newline,'split');
    
    if isequal(ccTYlines{1}(1:10),'FUNCTIONS:') % maybe always true
        ccTYlines(1) = [];
    end
    if isempty(ccTYlines{end}) % maybe always true
        ccTYlines(end) = [];
    end
    iVarLinesTY = find(cellfun(@(x) ~isequal(x(1),' '),ccTYlines));
    varNamesTY = cellfun(@(x) x(1:strfind(x,':')-1),ccTYlines(iVarLinesTY),...
        'uniformoutput',false);
    whichTYlines = find(ismember(varNamesTY,vName));
    currVarLines = [];
    for iwtyl = 1:length(whichTYlines)
        nextVar = iVarLinesTY(find(iVarLinesTY > iVarLinesTY(whichTYlines(iwtyl)),1));
        if isempty(nextVar)
            lastLineToCheck = length(ccTYlines);
        else
            lastLineToCheck = nextVar-1;
        end
        linesToCheck = ccTYlines(iVarLinesTY(whichTYlines(iwtyl))+1:lastLineToCheck);
        linesToCheck = cellfun(@(x) x(strfind(x,':')+1:end),linesToCheck,...
            'uniformoutput',false);
        lineStr = join(linesToCheck);
        currVarLines = [currVarLines,unique(str2double(lineStr{1}))];
    end
    allLines = unique(currVarLines);
    line1str = num2str(allLines(1));
end
