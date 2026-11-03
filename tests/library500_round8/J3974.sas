/* J3974 failure_summary_character_analysis, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data j3974a; length text $12; text='5'; run;
proc summary data=j3974a; var text; output out=j3974b sum=total; run;

proc datasets library=work nolist; delete j3974:; quit;
