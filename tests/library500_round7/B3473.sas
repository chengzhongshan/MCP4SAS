/* B3473 failure_character_length_limit, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:272 */

%let b3473len=%eval(32767+4);
data b3473a; length text $&b3473len; text='4'; run;
%symdel b3473len;

proc datasets library=work nolist; delete b3473:; quit;
