## Welcome to MEP 8 project, Style Guide for Matlab Code
This tool (mep8.m) was created to help cleaning Matlab code, similarly tp Python Enhancement Proposal 8 (**PEP8**).
 The goal - make matlab code easy to read and standardized. Please participate by testing it on your own code, send feedback and contribute to mep8.m

### Installation
The code [mep8.m](https://github.com/yuval-harpaz/mep8/blob/master/mep8.m) should work as stand-alone. If you want to apply mep8 on the default file [tests/test1.m](https://github.com/yuval-harpaz/mep8/blob/master/tests/test1.m), clone or download the whole repo. Then you can run mep8 with no input arguments.

### Input / Output
```markdown
[txt,issues]=mep8(fileName, overwrite);
```
**fileName** is <path+> file name of the code you want to check / fix.
**overwrite** is true when you want to replace the original code with the fixed version (**txt** output). when overwrite is true, a backup file is created for the original code.
**txt** is a new version of the code after fixing indentation and padding "=" with spaces. Most issue types are NOT fixed, in order not to break the code (renaming variables, ending for loops etc).
**issues** is a struct with fields describing the different issues diagnosed in different stages, such as missing ends to for loops, bad indentation, too short variable names (one letter) or variable names which are built-in matlab functions.
you can run on default test file:
```markdown
mep8;
```
### Status
The code runs checkcode and indentcode to use inherent matlab tools. It then uses splitcode (see a copy [here](https://github.com/pdollar/toolbox/blob/master/external/m2html/private/splitcode.m)) which is a [M2HTML](https://www.artefact.tk/software/matlab/m2html/) function. This helps us decide where comments and strings are in the text. I went further to pad equal signs with spaces, but not when in strings or comments. a ToDo list, as well as code, input and output is in [mep8.html](https://yuval-harpaz.github.io/mep8/html/mep8.html)

