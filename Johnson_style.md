
##1. Naming conventions##
1.1. Variables
1.1.1 Variable names should be in mixed case starting with lower case.
1.1.2 An alternative technique is to use underscore to separate parts of a compound variable name.
1.1.3 Variables with a large scope should have meaningful names. Variables with a small
scope can have short names. One letter variables (i, j, k, m, n, x, y and z.) should not used outside a few lines of code. Using variable names i or j may become an issue because they represent a built in matlab imaginary elements.
	* I dislike single letter variables because looking them up with ctrl+f is difficult. I often use double letters for that (e.g for ii = 1:10). I even prefer uppercase single letter (e.g. I = imread(‘peppers.png’);)
1.1.4 prefix n should be used for variables representing the number of objects. m can be used for number of rows.
1.1.5 A convention on pluralization should be followed consistently.
1.1.6 An acceptable alternative for the plural is to use the suffix Array.
	* I don’t like this suggestion and I haven’t seen this in use.
1.1.7 Variables representing a single entity number can be suffixed by No or prefixed by i.
1.1.8 Iterator variables should be named or prefixed with i, j, k etc.
1.1.9 For nested loops the iterator variables should be in alphabetical order.
1.1.10 For nested loops the iterator variables should be helpful names.
1.1.11 Negated boolean variable names should be avoided.
1.1.12 Acronyms, even if normally uppercase, should be mixed or lower case.
	*I disagree. I prefer isDVD  over isDvd. When acronym is used as variable lower-case is fine with me (html) but I think checkTIFFformat should be acceptable.
1.1.13 MATLAB can produce cryptic error messages or strange results if any of its reserved words or builtin special values is redefined.

1.2. Constants
	*I don’t think constants should be named differently than other variables.
1.2.1 Named constants (including globals) should be all uppercase using underscore to
separate words.
	*All upper-case look bad. They come from archaic C code where macros are used (preprocessor issues). Since even in C / C++ constants are not necessarily all uppercase I see no merit in adopting this bulky stile in Matlab. 

1.3 Structures
1.3.1 Structure names should begin with a capital letter.
	* I don’t know about that. Should there be a different name convention also for cell arrays, objects etc? I say we treat all variables equally or we end up we code that has many naming conventions.
1.3.2 The name of the structure is implicit, and need not be included in a fieldname.
Repetition is superfluous in use, as shown in the example.
1.4 Functions
1.4.1 The names of functions should document their use.
1.4.2 An exception is the use of abbreviations or acronyms widely used in mathematics.
max(.), gcd(.)
1.4.3 Names of functions should be written in lower case.
1.4.4 Some people prefer to use underscores in function names to enhance readability.
1.4.5 Others use the naming convention proposed here for variables.
1.4.6 Functions with a single output can be named for the output.
1.4.7 Functions with no output argument or which only return a handle should be named after
what they do.
1.4.8 The prefixes get/set should generally be reserved for accessing an object or property.
1.4.9 The prefix compute can be used in methods where something is computed.
1.4.10 The prefix find can be used in methods where something is looked up.
1.4.11 The prefix initialize can be used where an object or a concept is established.
1.4.12 The prefix is should be used for boolean functions.
1.4.13 There are a few alternatives to the is prefix that fit better in some situations.
1.4.14 Complement names should be used for complement operations.
Reduce complexity by symmetry (e.g. get/set, add/remove, etc)
1.4.15 Avoid unintentional shadowing (having two or more functions with the same name)

1.5 General
1.5.1 Names of dimensioned variables and constants should usually have a units suffix.
1.5.2 Abbreviations in names should be avoided.
1.5.3 Domain specific phrases that are more naturally known through their abbreviations or acronyms should be kept abbreviated.
1.5.4 Consider making names pronounceable.
1.5.5 All names should be written in English.

##2. Files and Organization##
2.1 M Files
2.1.1 Modularize. The best way to write a big program is to assemble it from well designed small pieces. Code longer than two editor screens is a candidate for partitioning.
	*I think sometimes it is better to follow the flow of a long script than jumping from file to file. The two screens limit is too short for my taste.
2.1.2 The use of arguments is almost always clearer than the use of globals.
2.1.3 Structures can be used to avoid long lists of input or output arguments.


2.1.4 All subfunctions and many functions should do one thing very well.
2.1.5 Every function should hide something.
2.1.6 Use existing functions.
2.1.7 Any block of code appearing in more than one m-file should be considered for packaging as a function.
2.1.8 A function used by only one other function should be packaged as its subfunction in the same file.
2.1.9 Write a test script for every function.
2.2 Input and Output
2.2.1 Make input and output modules.
2.2.2 Avoid mixing input or output code with computation, except for preprocessing, in a single function. Mixed purpose functions are unlikely to be reusable.
2.2.3 Format output for easy use.
If the output will most likely be read by a human, make it self descriptive and easy to read.
If the output is more likely to be read by software than a person, make it easy to parse.
If both are important, make the output easy to parse and write a formatter function to produce a human readable version.

##3. Statements##
3.1 Variables and constants
3.1.1 Variables should not be reused unless required by memory limitation.
3.1.2 Related variables of the same type can be declared in a common statement.
Unrelated variables should not be declared in the same statement.
3.1.3 Consider documenting important variables in comments near the start of the file.
3.1.4 Consider documenting constant assignments with end of line comments.
3.1.5 Use of global variables and constants should be minimized.

3.2 Loops
3.2.1 Loop variables should be initialized immediately before the loop.
3.2.2 The use of break and continue in loops should be minimized.
3.2.2 The end lines in nested loops can have comments
	*I tend to disagree. 

3.3. Conditionals
3.3.1 Complex conditional expressions should be avoided. Introduce temporary logical
variables instead.
3.3.2 The usual case should be put in the if-part and the exception in the else-part of an if else
statement.
3.3.3 The conditional expression if 0 should be avoided.
3.3.4 A switch statement should include the otherwise condition.
3.3.5 The switch variable should usually be a string.

3.4 General
3.4.1 Avoid cryptic code. “Good programmers write code that humans can
understand”.
3.4.2 Use parentheses. MATLAB has documented rules for operator precedence, but if there might be any doubt, use parentheses to clarify expressions.
3.4.3 The use of numbers in expressions should be minimized. 
3.4.4 Floating point constants should always be written with a digit before the decimal point.
3.4.5 Floating point comparisons should be made with caution.

##4. Layout, Comments and Documentation##
4.1 Layout
4.1.1 Content should be kept within the first 80 columns.
4.1.2 Lines should be split at graceful points.
4.1.3 Basic indentation should be 3 or 4 spaces.
	*Stick to four spaces!
4.1.4 In general a line of code should contain only one executable statement.
4.1.5 Short single statement if, for or while statements can be written on one line.
4.2 White Space
4.2.1 Surround =, &, and| by spaces.
4.2.2 Conventional operators can be surrounded by spaces. This practice is controversial.
4.2.3 Commas can be followed by a space. Some programmers leave them out.
4.2.4 Semicolons or commas for multiple commands in one line should be followed by a space character.
4.2.5 Logical groups of statements within a block should be separated by one blank line.
4.2.6 Blocks should be separated by more than one blank line. Another approach is to use the comment symbol followed by a repeated character such as * or -.
4.2.7 Use alignment wherever it enhances readability.
	* This relates mainly to split lines. I tend to disagree as it breaks regularity of indentation

4.3 Comments
4.3.1 Comments cannot justify poorly written code.
4.3.2 Comments should agree with the code, but do more than just restate the code.
4.3.3 Comments should be easy to read.
4.3.4 There should be a space between the % and the comment text.
4.3.5 Comments should start with an upper case letter and end with a period.
4.3.6 Comments should usually have the same indentation as the statements referred to.
4.3.7 Function header comments should support the use of help and lookfor.
4.3.8 Function header comments should discuss any special requirements for the input
arguments.
4.3.9 Function header comments should describe any side effects.
4.3.10 In general the last function header comment should restate the function line.
4.3.11 Writing the function name using uppercase in the function header is controversial.
4.3.12 Avoid clutter in the help printout of the function header. There should be a blank line between the header comments and these comments so that they are not displayed in response to help.
4.3.13 All comments should be written in English.

4.4 Documentation
4.4.1 Formal documentation - Documentation should include a readable description of what the code is supposed to do (Requirements), how it works (Design), which functions it depends on and how it is used by other code (Interfaces), and how it is tested. 
4.4.2 Consider writing the documentation first.
4.4.3 Changes - The professional way to manage and document code changes is to use a source control tool. For very simple projects, adding change history comments to the function files is certainly better than nothing.

