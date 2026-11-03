/* J3979 failure_summary_character_analysis, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data j3979a; length text $12; text='10'; run;
proc summary data=j3979a; var text; output out=j3979b sum=total; run;

proc datasets library=work nolist; delete j3979:; quit;
