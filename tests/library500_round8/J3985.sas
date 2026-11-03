/* J3985 failure_princomp_character_analysis, N=6; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3985a; length text $12; text='6'; run;
proc princomp data=j3985a noprint; var text; run;

proc datasets library=work nolist; delete j3985:; quit;
