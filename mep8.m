function [txt1,issues] = mep8(fileName,overwrite)
% Checks style issues in matlab code, fixes and overwrites if requested.
%% Input - output
%  - fileName is *.m text file with code to check / fix
%  - overwrite is true or false. when true, fileName is overwritten and a
% backup file is created, ending in bkp.m
%  - txt1 is a string containing fixed code
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

%% To Do
%  - polish and test on more code
%  - decide what to do with * / .^ etc
%  - try avoiding extra spaces inside code lines
%  - try add spaces after , ; and such in middle of line, but not before
%  - check variable names - this is a hard one, make lower first letter etc
%  - do something about line lengths

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

%% check compatibility / code warnings
disp('running checkcode: ')
issuesCodecheck = checkcode(fileName,'-string','-config=factory');
% process code to find variable names etc
% see http://undocumentedmatlab.com/blog/parsing-mlint-code-analyzer-output
ccEdit = checkcode(fileName,'-edit'); % -ty gives variable lines
ccEdit=ccEdit(1).message;
if isempty(issuesCodecheck)
    fprintf('\b done \n\n')
else
    disp(issuesCodecheck);
end
issues.codeCheck=issuesCodecheck;
%% read text file
f = fopen(fileName);
txt0 = native2unicode(fread(f,'uint8=>uint8')');
fclose(f);
% replace return \r with newline \n
txt0 = regexprep(txt0, '\r\n?', '\n');
% make sure last character is newline
if ~isequal(txt0(end),newline)
    txt0(end+1) = newline;
end

%% use matlab automatic indentation to add / remove spaces
disp('checking bad indentations :')
txt1 = indentcode(txt0);
% find newline location in orig (0) and new text (1)
newLines0 = regexp(txt0,'\n');
newLines1 = regexp(txt1,'\n');
if ~isequal(length(newLines0),length(newLines1))
    error('indented code and orig have different numbers of lines');
end
%location of line beginning in texts
startLine0 = [1,newLines0(1:end-1)+1];
startLine1 = [1,newLines1(1:end-1)+1];
% go line by line and check differences in spaces location
% along the way, process txt1 and label the contents
%
content=repmat('c',1,length(txt1)); % c  is for code (not cookey)
row=nan(size(txt1));
content(strfind(txt1,newline))='n';
issuesIndent = '';
for linei = 1:length(startLine0)
    line0 = txt0(startLine0(linei):newLines0(linei)-1);
    line1 = txt1(startLine1(linei):newLines1(linei)-1);
    msg = '';
    lin = num2str(linei);
    spaceIdx0 = ismember(line0,' ');
    spaceIdx1 = ismember(line1,' ');
    % check length of indentation
    indent0 = find(~spaceIdx0,1);
    indent1 = find(~spaceIdx1,1);
    
    if isempty(indent1) && any(spaceIdx1) % a line with nothing but spaces
        content(startLine1(linei):startLine1(linei)+length(line1)-1)='i';
    elseif indent1>1 % a line with spaces and then something else
        content(startLine1(linei):startLine1(linei)+indent1-2)='i';
    end
    row(startLine1(linei):newLines1(linei))=linei;
    % split to look for strings and comments (from m2html)
    splitc = splitCode(line1);
    start=startLine1(linei); % marks beginning of split strings
    for spliti=1:length(splitc)
        if ~isempty(splitc{spliti})
            switch splitc{spliti}(1)
                case '%'
                    content(start:start+length(splitc{spliti})-1)='%';
                case ''''
                    content(start:start+length(splitc{spliti})-1)='''';
            end
        end
        start=start+length(splitc{spliti}); % location of next split
    end
    
    if ~strcmp(line0,line1)
        if indent1>indent0
            num = num2str(indent1-indent0);
            msg = ['add ',num,' spaces. '];
        elseif indent1<indent0
            num = num2str(indent0-indent1);
            msg = ['remove ',num,' spaces. '];
        end
        if sum(~spaceIdx0) == sum(~spaceIdx1)
            lastNotSpace0 = find(~spaceIdx0,1,'last');
            lastNotSpace1 = find(~spaceIdx1,1,'last');
            if lastNotSpace1<length(line1)
                error('last fixed charecter should not be space')
            end
            if lastNotSpace0<length(line0)
                msg = [msg,num2str(length(line0)-lastNotSpace0),...
                    ' extra spaces in end of line'];
            end
        end
        issuesIndent = [issuesIndent,'L ',lin,': ',msg,newline];
    end
end
if isempty(issuesIndent)
    fprintf('\b done \n\n')
else
    disp(issuesIndent)
end
issues.indent=issuesIndent;

%% look for '=' or other stuff to pad with spaces
disp(['padding ',spacePad,' with spaces: '])
toPad = ismember(txt1,spacePad);
insertSpace = toPad; % make space after "="
insertSpace(find(toPad)-1) = true; % make space before "="
% find ~= <= and >=
logi = find(ismember(txt1,noSpaceNear));
if ~isempty(logi)
    %spacei = find(insertSpace);
    [~,ii] = ismember(logi,find(toPad)-1);
    if any(ii)
        logi = logi(ii>0);
        insertSpace(logi) = false;
        insertSpace(logi-1) = true;
    end
end
% FIXME - space before ~=  as in "y = x~= 5"
insertSpace(ismember(txt1,' ')) = false; % dont insert space after space
insertSpace(find(ismember(txt1,' '))-1) = false;  % dont insert space before space
% avoid touching strings and comments
insertSpace(ismember(content,'%')) = false;
insertSpace(ismember(content,'''')) = false;
tmp = [strrep(txt1,newline,'N');strrep(num2str(insertSpace),' ','');content];
disp('location of "insert space after = "');
disp(tmp);
if ~isequal(unique(content(insertSpace)),'c')
    warning('space insertion not in code "c"')
end
spacedLines=unique(row(insertSpace));
issuesSpace='';
for linei=1:length(spacedLines)
    loc=find(insertSpace & row == spacedLines(linei));
    padded=spacePad(ismember(spacePad,txt1(loc(1)-1:loc(end))));
    issuesSpace=[issuesSpace,'L ',num2str(spacedLines(linei)),': ',...
        padded,' padded with spaces.',newline];
end
issues.spacePad=issuesSpace;
for inserti = sort(find(insertSpace),'descend')
    txt1 = insertAfter(txt1,inserti,' ');
    content = insertAfter(content,inserti,'c');
end
%% variable names
vLoc = strfind(ccEdit,' V ');
varLines=regexp(ccEdit,newline,'split')';
varLines=varLines(contains(varLines,' V '));
if isempty(varLines)
    error('no variables in code?')
end
% get variable names from text
spaceLims=find(diff(ismember(varLines{1},' '))>0,2)+1;
varNames = cellfun(@(x) strrep(x(spaceLims(1):spaceLims(2)),' ',''),varLines, 'UniformOutput',false);
startWithUpper = cellfun(@(x) isequal(x(1),upper(x(1))),varNames);
if any(startWithUpper)
    disp(join(['Variables with upper-case first letter:',varNames(startWithUpper)']))
end
%% line length


%% overwrite if requested, save backup ('*bkp.m')
if overwrite && ~isequal(txt1,txt0)
    [pat1,pat2,pat3] = fileparts(fileName);
    if ~isempty(pat1)
        pat1 = [pat1,'/'];
    end
    bkpNew = false;
    ii = 0;
    while bkpNew == false
        ii = ii+1;
        backup = [pat1,pat2,'_',num2str(ii),'bkp',pat3];
        if ~exist(backup,'file')
            bkpNew = true;
            
            fbkp = fopen(backup,'w');
            fwrite(fbkp,txt1);
            fclose(fbkp);
            if ~exist(backup,'file')
                error('backup file not created, not overwriting')
            end
            f = fopen(fileName,'w');
            fwrite(f,txt1);
            fclose(f);
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

function splitc = splitCode(code)
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
iquote = strfind(code,'''');
quotetransp = [double('_''.)}]') ...
    double('A'):double('Z') ...
    double('0'):double('9') ...
    double('a'):double('z')];
flagstring = 0;
flagdoublequote = 0;
jquote = [];
for i=1:length(iquote)
    if ~flagstring
        if iquote(i) > 1 && any(quotetransp == double(code(iquote(i)-1)))
            % => 'transpose';
        else
            % => 'beginstring';
            jquote(size(jquote,1)+1,:) = [iquote(i) length(code)];
            flagstring = 1;
        end
    else % if flagstring
        if flagdoublequote || ...
                (iquote(i) < length(code) && strcmp(code(iquote(i)+1),''''))
            % => 'midstring';
            flagdoublequote = ~flagdoublequote;
        else
            % => 'endstring';
            jquote(size(jquote,1),2) = iquote(i);
            flagstring = 0;
        end
    end
end

%- Find if a portion of code is a comment
ipercent = strfind(code,'%');
jpercent = [];
for i=1:length(ipercent)
    if isempty(jquote) || ...
            ~any((ipercent(i) > jquote(:,1)) & (ipercent(i) < jquote(:,2)))
        jpercent = [ipercent(i) length(code)];
        break;
    end
end

% YH: this segment misbehaves
% %- Find continuation punctuation '...'
% icont = strfind(code,'...');
% for i=1:length(icont)
%     if (isempty(jquote) || ...
%             ~any((icont(i) > jquote(:,1)) && (icont(i) < jquote(:,2)))) && ...
%             (isempty(jpercent) || ...
%             icont(i) < jpercent(1))
%         jpercent = [icont(i) length(code)];
%         break;
%     end
% end

%- Remove strings inside comments
if ~isempty(jpercent) && ~isempty(jquote)
    jquote(jquote(:,1) > jpercent(1),:) = [];
end

%- Split code in a cell array of strings
icode = [jquote ; jpercent];
splitc = {};
if isempty(icode)
    splitc{1} = code;
elseif icode(1,1) > 1
    splitc{1} = code(1:icode(1,1)-1);
end
for i=1:size(icode,1)
    splitc{end+1} = code(icode(i,1):icode(i,2));
    if i < size(icode,1) && icode(i+1,1) > icode(i,2) + 1
        splitc{end+1} = code((icode(i,2)+1):(icode(i+1,1)-1));
    elseif i == size(icode,1) && icode(i,2) < length(code)
        splitc{end+1} = code(icode(i,2)+1:end);
    end
end