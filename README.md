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

## Style Guidelines
### 1. function and variable names
[Richard Johnson](http://www.datatool.com/downloads/matlab_style_guidelines.pdf) suggested that:
* Variable names should be in mixed case starting with lower case (e.g. img, imageSize, imageEdgeColor)
* Function names should be lowercase (e.g. plot, findpeaks)
* Variable names should reflect their scope, use short names (one letter) when the variable used in few adjacent lines, but longer informative names when the variable is used throughout the script.
* i and j are reserved Matlab names for imaginary numbers and should not be used as variable names. One can use ii and jj instead ([see also [here](https://stackoverflow.com/questions/14790740/using-i-and-j-as-variables-in-matlab))
* indices may be formatted with lowercase i and then a capitalized word (e.g. iSample).  

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;I tested Matlab toolbox to see to see how frequent it is to have underscores in function names, and other attributes of file names. Although many functions and variable names follow the above guidelines, there are also many functions with uppercase letters  (e.g. plotCamera), and also some variable names and functions with underscore separating between words (e.g. make_gnu_tfl_table). The most common for loop variable is i and there are as many index variables with the format iName as all lowercase iname. see a brief report [here](html/statistics.html).  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;We can put it to a vote but a stand should be taken. For pep8 to be style guideline we can't simply say that everything goes. It has to conform with Matlab built in function names and the way things are written, but while we can't choose some improbable format, inconsistency in Matlab code forces us to choose.  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Since I am the only pep8 community now, my vote is that there should be a difference between function names and variable names, for names longer than onw word.  
**1.1 Variable names** comprised of two parts or more should have a capital letter separator (**variableName**).  
**1.2 Function names** with two words should be written in all lowercase format (**functionname**). When the two words are long [length(functionname) > 15], or when the name of the function consists of more than two words, name parts should be separated by underscore (**long_function_name**).  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Although the use of i in for loops is very common, I prefer the [use of ii](https://stackoverflow.com/questions/14790740/using-i-and-j-as-variables-in-matlab). When testing whether variable names shadow existing functions a message will be printed that i shadows a buit-in function.  
**1.3 Using i or j** as variable names should be avoided. Use **ii** and **jj** instead.  
**1.4 variables with large scope** should have informative names (**informativeName**, not **~~inm~~**).  
**1.5 Index of array** should start with an i followed by a capitalized word (**iArray**).

### 2. Layout  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Here we should consider what to do with blank spaces. As a rule, Matlab Editor's Ctrl+i should fix most indentation issues, and deviation from Ctrl+ied text may be considered bad style. So:  
**2.1 Indentation** should be 4 spaces long.  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Spaces around operators and different characters are more difficult to deal with. There is concensus for adding spaces around the signs < = > & |, and combinations such as || and ~=.  
**2.2 Equals sign** = for assignments and **relational operators** [see here](https://www.mathworks.com/help/matlab/matlab_prog/array-comparison-with-relational-operators.html) should be padded with zeros (e.g **`a = 10;`**).  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;However, you sometimes see programmers writing a = b*c; and others a = b * c. For short expressions padding operators with spaces is tidy, but I find it hard to read longer spaced expressions such as a = b .^ c * d / (e + someFvariable .^2). My vote:  
**2.3 Arithmetic operators** ^/\*+- should not be padded with spaces **`a = b*c/d;`**. For one operation lines, this is not bad style to pad with spaces **`a = b * c;`**. 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;


