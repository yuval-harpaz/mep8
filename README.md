## Welcome to MEP 8 project, Style Guide for Matlab Code
This tool (mep8.m) was created to help cleaning Matlab code, similarly tp Python Enhancement Proposal 8 (**PEP8**).
 The goal - make matlab code easy to read and standardized.  
Matlab has no formal set of style rules, but there is Richard Johnson's [unofficial work](http://www.datatool.com/downloads/matlab_style_guidelines.pdf) which I find important (see some opinions [here](https://stackoverflow.com/questions/17453244/modern-matlab-codestyle-what-is-missing))  
Please participate by testing it on your own code, send feedback and contribute to mep8.m

### Installation
The code [mep8.m](https://github.com/yuval-harpaz/mep8/blob/master/mep8.m) should work as stand-alone. If you want to apply mep8 on the default file [tests/test1.m](https://github.com/yuval-harpaz/mep8/blob/master/tests/test1.m), clone or download the whole repo. Then you can run mep8 with no input arguments.

### Input / Output
```markdown
[txt,issues]=mep8(fileName, overwrite);
```
**fileName** is <path+> file name of the code you want to check / fix.  
**overwrite** is true when you want to replace the original code with the fixed version (**txt** output). when overwrite is true, a backup file is created for the original code.  
**txt** is a new version of the code after fixing indentation and padding "=" with spaces. Most issue types are NOT fixed, in order not to break the code (renaming variables, ending for loops etc).  
**issues** is a struct with fields describing the different issues diagnosed in different stages, such as missing ends to for loops, bad indentation, too short variable names (one letter) or variable names which are built-in matlab functions. issues are also printed at different stages of mep8 execution, so running mep8 with no output arguments will give you everything.


### Examples
you can run on default test file:
```markdown
mep8;
```
you can run on some other file in any of these ways:
```markdown
mep8('commonplotfunc');
mep8('commonplotfunc.m');
mep8('/path_to_file/commonplotfunc.m');
[newCode, issues]=('commonplotfunc',false);
```
### Status
The code runs **checkcode** and **indentcode** to use inherent matlab tools.  
It then uses **splitcode** (see a copy [here](https://github.com/pdollar/toolbox/blob/master/external/m2html/private/splitcode.m)) which is an [M2HTML](https://www.artefact.tk/software/matlab/m2html/) function. This helps us decide where comments and strings are in the text.  
Equal signs are then **padded with spaces**, but not when in strings or comments. < > & and | are treated similarly.  
**Variable names** are then treated in order to find bad style names: too sort (one letter), two words with no decent seperator (underscore or upperCase letter), and variables that are existing matlab functions. For this I used checkcode with some [undocumented mlint options](http://undocumentedmatlab.com/blog/parsing-mlint-code-analyzer-output), a list of english words as posted [here](https://raw.githubusercontent.com/first20hours/google-10000-english/master/google-10000-english.txt) and the function exist.
A ToDo list, as well as code, input and output (result of publish('mep8.m','format','html')) is in [mep8.html](https://yuval-harpaz.github.io/mep8/html/mep8.html)

