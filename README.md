## Welcome to MEP 8 project, pep8 for matlab
This toom (mep8.m) was created with the thought of making a tool to enhance matlab code style, similarly tp Python Enhancement Proposal 8 (**PEP8**).
Please participate, test and cotribute. This is more work than one volunteer could do. The goal - make matlab code easy to read and standardized.

### Installation
The code [mep8.m](https://github.com/yuval-harpaz/mep8/blob/master/mep8.m) should work as stand-alone. If you want it to run on the default [tests/test1.m](https://github.com/yuval-harpaz/mep8/blob/master/tests/test1.m), clone or download the whole repo. Then you can run mep8 with no input arguments.

### Examples
run:
```markdown
[txt,issues]=mep8(fileName);
```
you can run on default test file:
```markdown
mep8;
```
### Status
The code runs checkcode and indentcode to use inherent matlab tools. It then uses splitcode (see a copy [here](https://github.com/pdollar/toolbox/blob/master/external/m2html/private/splitcode.m)) which is a [M2HTML](https://www.artefact.tk/software/matlab/m2html/) function. This helps us decide where comments and strings are in the text. I went further to pad equal signs with spaces, but not when in strings or comments. a ToDo list, as well as code, input and output is in [mep8.html](https://yuval-harpaz.github.io/mep8/html/mep8.html)

