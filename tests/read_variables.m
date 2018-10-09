function varName = read_variables
[~,list] = system('find /media/innereye/1T/Programs/MATLAB/R2017b/toolbox/ -type f -name "*.m"');
list=regexp(list,newline,'split')';
varName={}; funcName = {};
for iFunc = 1:length(list)
    try
        %eval(['open ',list{iFunc}])
        txtEdit = mlintmex('-edit',list{iFunc});
        varLines = regexp(txtEdit,newline,'split')';
        varLines(contains(varLines,'VOID'))=[];
        funcLines = varLines(contains(varLines,' F '));
        varLines = varLines(contains(varLines,' V '));
        if ~isempty(varLines)
            spaceLims = find(diff(ismember(varLines{1},' ')) > 0,2)+1;
            vn = cellfun(@(x) strrep(x(spaceLims(1):spaceLims(2)),' ',''),varLines, 'UniformOutput',false);
            fn = cellfun(@(x) strrep(x(spaceLims(1):spaceLims(2)),' ',''),funcLines, 'UniformOutput',false);
            vn = unique(vn);
            fn = unique(fn);
            
            varName(end+1:end+length(vn),1)=vn;
            funcName(end+1:end+length(fn),1)=fn;
        end
        
    end
end

disp(varName);

[a,b,c]=unique(varName);

save /media/innereye/1T/Docs/MATLAB/funcNames2 funcName varName
% disp([num2str(round(100*sum(contains(funcName,'_'))/length(funcName),1)),'% got underscore'])
% up=cellfun(@(x) ~isequal(x,lower(x)),funcName);
% disp([num2str(round(100*sum(up)/length(funcName),1)),'% got uppercase']) 
% disp([num2str(round(100*sum(num)/length(funcName),1)),'% got numbers'])
%% plot
longerThan = 5; % only check stuff longer than 5 chars
figure;
subplot(1,2,1)
up=cellfun(@(x) sum(ismember(x,upper(x))),funcName);
us=cellfun(@(x) sum(ismember(x,'_')),funcName);
up1=cellfun(@(x) sum(isequal(x(1),upper(x(1)))),funcName);
num=cellfun(@(x) any(ismember('0123456789',x)),funcName);
lenName = cellfun(@(x) length(x),funcName);
n1up=sum(up==1 & ~up1 & ~num & lenName>longerThan);
n1us=sum(us==1 & ~num & lenName>longerThan);
low=cellfun(@(x) isequal(x,lower(x)),funcName);
nLow=sum(low &  ~num & lenName>longerThan);
numSum=cellfun(@(x) sum(ismember('0123456789',x)),funcName);
n1num=sum(numSum==1 & low & lenName>longerThan);
pie([nLow,n1us,n1up,n1num,sum(lenName>longerThan)-sum([nLow,n1us,n1up,n1num])],...
    {'lowercase','one\_underscore','oneUppercase','one1number','other'});
title('functions')
subplot(1,2,2)
up=cellfun(@(x) sum(ismember(x,upper(x))),varName);
us=cellfun(@(x) sum(ismember(x,'_')),varName);
up1=cellfun(@(x) sum(isequal(x(1),upper(x(1)))),varName);
num=cellfun(@(x) any(ismember('0123456789',x)),varName);
lenName = cellfun(@(x) length(x),varName);
n1up=sum(up==1 & ~up1 & ~num & lenName>longerThan);
n1us=sum(us==1 & ~num & lenName>longerThan);
low=cellfun(@(x) isequal(x,lower(x)),varName);
nLow=sum(low &  ~num & lenName>longerThan);
numSum=cellfun(@(x) sum(ismember('0123456789',x)),varName);
n1num=sum(numSum==1 & low & lenName>longerThan);
pie([nLow,n1us,n1up,n1num,sum(lenName>longerThan)-sum([nLow,n1us,n1up,n1num])],...
    {'lowercase','one\_underscore','oneUppercase','one1number','other'});
title('variables')

