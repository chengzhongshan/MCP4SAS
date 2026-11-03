/* J3977 failure_summary_character_analysis, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data j3977a; length text $12; text='8'; run;
proc summary data=j3977a; var text; output out=j3977b sum=total; run;

proc datasets library=work nolist; delete j3977:; quit;
