/* J3972 failure_summary_character_analysis, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data j3972a; length text $12; text='3'; run;
proc summary data=j3972a; var text; output out=j3972b sum=total; run;

proc datasets library=work nolist; delete j3972:; quit;
