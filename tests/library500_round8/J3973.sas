/* J3973 failure_summary_character_analysis, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data j3973a; length text $12; text='4'; run;
proc summary data=j3973a; var text; output out=j3973b sum=total; run;

proc datasets library=work nolist; delete j3973:; quit;
