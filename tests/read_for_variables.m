function varName = read_for_variables
[~,list] = system('find /media/innereye/1T/Programs/MATLAB/R2017b/toolbox/ -type f -name "*.m"');
list=regexp(list,newline,'split')';
varName={};
for iFunc = 1:length(list)
    try
        %eval(['open ',list{iFunc}])
        fid = fopen(list{iFunc},'r');
        txt = native2unicode(fread(fid,'uint8=>uint8')');
        lines=regexp(txt,newline,'split');
        lines(~contains(lines,'for '))=[];
        if ~isempty(lines)
            for iLine=1:length(lines)
                percentLoc=find(ismember(lines{iLine},'%'),1);
                if ~isempty(percentLoc)
                    lines{iLine}(percentLoc:end)='';
                end
                if ~isempty(lines{iLine})
                    forLoc=strfind(lines{iLine},'for ');
                    forLoc=forLoc(1);
                    if forLoc>1
                        if mean(ismember(lines{iLine}(1:forLoc-1),' '))==1 % only spaces before for
                            lines{iLine}=lines{iLine}(forLoc:end); % remove spaces
                        end
                    end
                    forLoc=strfind(lines{iLine},'for ');
                    forLoc=forLoc(1);
                    if forLoc==1
                        firstEqual = strfind(lines{iLine}(5:end),'=')+4;
                        if ~isempty(firstEqual)
                            firstEqual=firstEqual(1);
                            str = strrep(lines{iLine}(5:firstEqual-1),' ','');
                            if isempty(str)
                                disp('?')
                            else
                                varName{end+1,1}=str;
                            end
                        end
                    end
                    % FIXME - get var name here
                end
            end
        end
        
    end
end

disp(varName);

[a,b,c]=unique(varName);

for ui = 1:length(a)
    count(ui,1)=sum(c == ui);
end
[count,order] = sort(count,'descend');
a=a(order);
ratio=count./sum(count);
%T=table(a,count,ratio);
NvarsToShow=30;
pRatio=ratio(1:NvarsToShow);
pRatio(NvarsToShow+1)=sum(ratio(NvarsToShow+1:end));
pName=a(1:30);
pName{end+1}='others';
% pie(pRatio,pName)
figure;
bar(100*pRatio,'linestyle','none')
box off
set(gca,'xtick',1:NvarsToShow+1,'xticklabel',pName,'ygrid','on','fontsize',12)
xtickangle(15)
ylabel('ratio (%)')
xlabel('variable name')
title('variable names in for loops')