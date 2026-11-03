/* J3976 failure_summary_character_analysis, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data j3976a; length text $12; text='7'; run;
proc summary data=j3976a; var text; output out=j3976b sum=total; run;

proc datasets library=work nolist; delete j3976:; quit;
