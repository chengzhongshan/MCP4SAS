/* J3989 failure_princomp_character_analysis, N=10; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3989a; length text $12; text='10'; run;
proc princomp data=j3989a noprint; var text; run;

proc datasets library=work nolist; delete j3989:; quit;
