/* B3472 failure_character_length_limit, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:272 */

%let b3472len=%eval(32767+3);
data b3472a; length text $&b3472len; text='3'; run;
%symdel b3472len;

proc datasets library=work nolist; delete b3472:; quit;
