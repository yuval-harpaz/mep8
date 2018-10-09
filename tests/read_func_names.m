function [func,line] = read_func_names
[~,list] = system('find /media/innereye/1T/Programs/MATLAB/R2017b/toolbox/ -type f -name "*.m"');
list=regexp(list,newline,'split')';
func={};
line={};
for iFunc = 1:length(list)
    try
        %eval(['open ',list{iFunc}])
        fid = fopen(list{iFunc},'r');
        txt = fgetl(fid);
        fclose(fid);
        funcLoc = strfind(txt,'function');
        if ~isempty(funcLoc)
            txtBefore = strrep(txt(1:funcLoc-1),' ','');
            if isempty(txtBefore)
                beforeOkay = true;
            elseif ~isequal(txtBefore(1),'%')
                beforeOkay = true;
            else
                beforeOkay=false;
            end
            txtAfter = txt(funcLoc+8:end);
            if isempty(txtAfter)
                afterOkay = false;
            elseif isequal(txtAfter(1),' ')
                afterOkay = true;
            else
                afterOkay = false;
            end
            if beforeOkay && afterOkay
                equalsLoc = strfind(txtAfter,'=');
                if ~isempty(equalsLoc)
                    txtAfter = txtAfter(equalsLoc+1:end);
                end
                txtAfter = strrep(txtAfter,' ','');
                alphaNum=false(1,length(txtAfter));
                alphaNum(regexp(txtAfter,'\w'))=true;
                if any(~alphaNum)
                    func{end+1,1}=txtAfter(1:find(~alphaNum,1)-1);
                else
                    func{end+1,1}=txtAfter;
                end
                line{end+1,1} = txt;
            end
        end
    end
end
empty=cellfun(@(x) isempty(x),func);
func=func(~empty);
line=line(~empty);
save /media/innereye/1T/Docs/MATLAB/funcNames func line
disp([num2str(round(100*sum(contains(func,'_'))/length(func),1)),'% got underscore'])
up=cellfun(@(x) ~isequal(x,lower(x)),func);
disp([num2str(round(100*sum(up)/length(func),1)),'% got uppercase'])
num=cellfun(@(x) any(ismember('0123456789',x)),func);
disp([num2str(round(100*sum(num)/length(func),1)),'% got numbers'])

up=cellfun(@(x) sum(ismember(x,upper(x))),func);
us=cellfun(@(x) sum(ismember(x,'_')),func);
up1=cellfun(@(x) sum(isequal(x(1),upper(x(1)))),func);
n1up=sum(up==1 & ~up1 & ~num);
n1us=sum(us==1 & ~num);
low=cellfun(@(x) isequal(x,lower(x)),func);
nLow=sum(low &  ~num);
num=cellfun(@(x) sum(ismember('0123456789',x)),func);
n1num=sum(num==1 & low);
figure;
p=pie([nLow,n1us,n1up,n1num,length(func)-sum([nLow,n1us,n1up,n1num])],...
    {'lowercase','one\_underscore','oneUppercase','one1number','other'});
t = p(1);
t.FontSize=14;
