/* B3474 failure_character_length_limit, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:272 */

%let b3474len=%eval(32767+5);
data b3474a; length text $&b3474len; text='5'; run;
%symdel b3474len;

proc datasets library=work nolist; delete b3474:; quit;
