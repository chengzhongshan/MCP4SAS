/* J3980 failure_summary_character_analysis, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data j3980a; length text $12; text='11'; run;
proc summary data=j3980a; var text; output out=j3980b sum=total; run;

proc datasets library=work nolist; delete j3980:; quit;
