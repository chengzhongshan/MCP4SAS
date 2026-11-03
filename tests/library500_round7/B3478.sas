/* B3478 failure_character_length_limit, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:272 */

%let b3478len=%eval(32767+9);
data b3478a; length text $&b3478len; text='9'; run;
%symdel b3478len;

proc datasets library=work nolist; delete b3478:; quit;
