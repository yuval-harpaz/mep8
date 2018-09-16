% function test1

for ii=1:10;
  x=5;  
    
    if ii==2
      x=x+1/3;
    elseif ii~=3
    x=ii;   
    elseif x >=1000
        x=999;
    elseif x<=0
        x = 1;
    elseif x >34
        x=34;
    elseif x <=54
        disp('x is okay I guess')
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
x = 5+3+10000-...
    34;
x = x+3+10000-...
    35; % comment here?
x = x+3+10000-...
    35; % comment there? with 'qoutes'?

