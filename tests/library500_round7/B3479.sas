/* B3479 failure_character_length_limit, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:272 */

%let b3479len=%eval(32767+10);
data b3479a; length text $&b3479len; text='10'; run;
%symdel b3479len;

proc datasets library=work nolist; delete b3479:; quit;
