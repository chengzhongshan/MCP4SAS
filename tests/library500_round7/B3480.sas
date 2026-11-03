/* B3480 failure_character_length_limit, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:272 */

%let b3480len=%eval(32767+11);
data b3480a; length text $&b3480len; text='11'; run;
%symdel b3480len;

proc datasets library=work nolist; delete b3480:; quit;
