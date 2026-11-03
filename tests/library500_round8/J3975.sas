/* J3975 failure_summary_character_analysis, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data j3975a; length text $12; text='6'; run;
proc summary data=j3975a; var text; output out=j3975b sum=total; run;

proc datasets library=work nolist; delete j3975:; quit;
