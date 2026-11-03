/* B3471 failure_character_length_limit, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:272 */

%let b3471len=%eval(32767+2);
data b3471a; length text $&b3471len; text='2'; run;
%symdel b3471len;

proc datasets library=work nolist; delete b3471:; quit;
