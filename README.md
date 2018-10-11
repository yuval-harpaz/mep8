## Welcome to MEP 8 project, Style Guide for Matlab Code
This tool (mep8.m) was created to help cleaning Matlab code, similarly tp Python Enhancement Proposal 8 (**PEP8**).
 The goal - make matlab code easy to read and standardized.  
Matlab has no formal set of style rules, but there is Richard Johnson's [unofficial work](http://www.datatool.com/downloads/matlab_style_guidelines.pdf) which I find important (see some opinions [here](https://stackoverflow.com/questions/17453244/modern-matlab-codestyle-what-is-missing)). Some features have been implemented, so now you can use mep8 to fix indentations, pad equals signs with zeros etc, and even overwrite the original code with the fixed version (a backup file is saved). In addition, a report of issues and potential issues is reported, such as shadowing existing functions with variable names. Many of these issues cannot be fixed automatically, so use the report to manually fix your code.   
Please participate by testing it on your own code, send feedback and contribute to mep8.m code.
  
### mep8 style in a nutshell
**variable names** should look like `ii`, `iName` `itemName` or `itemToPlot`.  
`k` is okay for 15 lines of code. `kk` is acceptable for 30. For a variable spanning the whole script you need a more `informativeName`.  
**function names** should look like `prepare`, `preparestring` or `prepare_long_string`.  
**space padding**: `a = b*c/d` is okay,  `a=b*c/d` is bad;  
**shadowing** `plot = rand(300,300,3);` is bad because plot is already a thing im Matlab.

### Installation
The code [mep8.m](https://github.com/yuval-harpaz/mep8/blob/master/mep8.m) should work as a stand-alone. If you want to apply mep8 on the default file [tests/test1.m](https://github.com/yuval-harpaz/mep8/blob/master/tests/test1.m) (run mep8 with no input arguments), clone or download the whole repo.  

### Input / Output
```markdown
[txt,issues]=mep8(fileName,cfg,overwrite);
```
**fileName** is <path+> file name of the code you want to check / fix.  
**cfg** is a struct with the fields okayIssue and factory, It allows us to ignore Matlab issues which are not mep8 issues, and to deviate from mep8 if you wish to. See cfg.options in `help mep8`.  
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
mep8('mep8');
mep8('mep8.m');
mep8('/path_to_file/mep8.m');
cfg = [];
cfg.factory = true;
cfg.okayIssue = {'fileName';'might be unused'};
[newCode, issues] = mep8('mep8',cfg,false);
```
### Status
The code runs **checkcode** and **indentcode** to use inherent matlab tools.  
It then uses **splitcode** (see a copy [here](https://github.com/pdollar/toolbox/blob/master/external/m2html/private/splitcode.m)) which is an [M2HTML](https://www.artefact.tk/software/matlab/m2html/) function. This helps us decide where comments and strings are in the text.  
Equals signs are then **padded with spaces**, but not when in strings or comments. < > & and | are treated similarly.  
**Variable names** are then searched for bad style names: too short for their scope (one letter name for a variable appearing in 150 lines of code), two words with no decent seperator (upperCase letter), and variables that are existing matlab functions. For this I used checkcode with some [undocumented mlint options](http://undocumentedmatlab.com/blog/parsing-mlint-code-analyzer-output), a list of english words as posted [here](https://raw.githubusercontent.com/first20hours/google-10000-english/master/google-10000-english.txt) and the function exist.
A ToDo list, as well as code, input and output (result of publish('mep8.m','format','html')) is in [mep8.html](https://yuval-harpaz.github.io/mep8/html/mep8.html)

## Style Guidelines
Style issues are discussed with reference to the summary of Richard Johnson's document ([Johnson_style.md](https://github.com/yuval-harpaz/mep8/blob/master/Johnson_style.md)). Items prefixed with RJ indicate reference to this summary (e.g. RJ1.1.1).  
### 1. function and variable names
[Richard Johnson](http://www.datatool.com/downloads/matlab_style_guidelines.pdf) suggested that:
* Variable names should be in mixed case starting with lower case (e.g. img, imageSize, imageEdgeColor, RJ1.1.1)
* Function names should be lowercase (e.g. plot, findpeaks, RJ1.4.3)
* Variable names should reflect their scope (RJ1.1.3), use short names (one letter) when the variable used in few adjacent lines, but longer informative names when the variable is used throughout the script.
* i and j are reserved Matlab names for imaginary numbers and should not be used as variable names (RJ1.1.3). One can use ii and jj instead (as suggested [here](https://stackoverflow.com/questions/14790740/using-i-and-j-as-variables-in-matlab))
* indices may be formatted with lowercase i and then a capitalized word (e.g. iSample RJ1.1.7 and RJ1.1.8).  

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;I tested Matlab toolbox to see to see how frequent it is to have underscores in function names, and other attributes of file names. Although many functions and variable names follow the above guidelines, there are also many functions with uppercase letters  (e.g. plotCamera), and also some variable names and functions with underscore separating between words (e.g. make_gnu_tfl_table). The most common for loop variable is i and there are as many index variables with the format iName as all lowercase iname. see a brief report [here](https://yuval-harpaz.github.io/mep8/html/statistics.html).  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;We can put it to a vote but a stand should be taken. For pep8 to be style guideline we can't simply say that everything goes. It has to conform with Matlab built in function names and the way things are written, but while we can't choose some improbable format, inconsistency in Matlab code forces us to choose.  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Since I am the only pep8 community now, my vote is that there should be a difference between function names and variable names, for names longer than onw word.  
**1.1 Function names**  
Names which are two words attached should be written in all lowercase format (**functionname**). When the two words are long [length(functionname) > 15], or when the name of the function consists of more than two words, name parts should be separated by underscore (**long_function_name**).  
**1.2 Variable names**  
**1.2.1** Names comprised of two parts or more should have a capital letter separator (**variableName**).  
**1.2.2** Use **ii** and **jj** instead of i and j, to avoid shadowing imaginary i and j.  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Although the use of i in for loops is very common, I prefer the [use of ii](https://stackoverflow.com/questions/14790740/using-i-and-j-as-variables-in-matlab). When testing whether variable names shadow existing functions a message will be printed that i shadows a buit-in function.  
**1.2.3 Scope** of variables determines the length of their names. Scope is the distance between the first (*line0*) and the last line (*line1*) where the variable appeared. More correctly, it is *line1*-*line0*+1. The minimum name length is the scope divided by 15, or 6, the smaller of the two.  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Example: variable x appears between line 11 and line 30. The scope is 30-11+1 = 20 lines. Since the length of x name is 1 character and since the maximum scope for 1 char names is 15 lines an issue will be reported.  
Another example: The scope of variable iImg (length of name = 4) is 150 lines. Since 15*4 < 150 the length of the name is too short. However, the minimum length of the name is not 10 chars (150/15) because the 6 is smaller.

**To Be Continued...**




