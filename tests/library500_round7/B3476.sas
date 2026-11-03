/* B3476 failure_character_length_limit, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:272 */

%let b3476len=%eval(32767+7);
data b3476a; length text $&b3476len; text='7'; run;
%symdel b3476len;

proc datasets library=work nolist; delete b3476:; quit;
