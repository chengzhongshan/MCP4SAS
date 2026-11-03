/* B3475 failure_character_length_limit, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:272 */

%let b3475len=%eval(32767+6);
data b3475a; length text $&b3475len; text='6'; run;
%symdel b3475len;

proc datasets library=work nolist; delete b3475:; quit;
