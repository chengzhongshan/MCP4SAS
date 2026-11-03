/* J3981 failure_princomp_character_analysis, N=2; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3981a; length text $12; text='2'; run;
proc princomp data=j3981a noprint; var text; run;

proc datasets library=work nolist; delete j3981:; quit;
