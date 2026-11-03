/* B3477 failure_character_length_limit, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:272 */

%let b3477len=%eval(32767+8);
data b3477a; length text $&b3477len; text='8'; run;
%symdel b3477len;

proc datasets library=work nolist; delete b3477:; quit;
