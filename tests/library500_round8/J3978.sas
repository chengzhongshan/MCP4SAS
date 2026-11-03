/* J3978 failure_summary_character_analysis, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data j3978a; length text $12; text='9'; run;
proc summary data=j3978a; var text; output out=j3978b sum=total; run;

proc datasets library=work nolist; delete j3978:; quit;
