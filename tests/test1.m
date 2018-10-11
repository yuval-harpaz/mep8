% this code is nonsensical, it does not run without errors. It has style
% issues detectable by running mep8; or mep8('tests/test1.m).
CONST1 = 15;
for ii=1:10;
  x=5;  
    
    if ii==2
      Xup=x+1/3*CONST1;
    elseif ii~=3
    x=ii;   
    elseif x <=54
        disp('x is okay I guess')
    elseif x~=15
        [~,order] = sort(x);
    end

end
str='I got  a =sign!';
disp(str)
% treat <= respectfully
disp(x)
txt0 = native2unicode(fread(f,'uint8=>uint8')');
disp(['here I test 3 dots + comment               XXXXXXXXXXXXX',... % here a comment lays
    ' more string here']);
disp('3 dots here ...  ') % more dots tests
m = 5+3+10000-...
    34;
x = x+3+10000-...
    35; % comment here?
finaltest = x+3+10000-...
    35; % comment there? with 'qoutes'?
sphere = 2*pi;

