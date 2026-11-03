/* J3971 failure_summary_character_analysis, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data j3971a; length text $12; text='2'; run;
proc summary data=j3971a; var text; output out=j3971b sum=total; run;

proc datasets library=work nolist; delete j3971:; quit;
