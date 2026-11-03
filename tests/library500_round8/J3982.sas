/* J3982 failure_princomp_character_analysis, N=3; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3982a; length text $12; text='3'; run;
proc princomp data=j3982a noprint; var text; run;

proc datasets library=work nolist; delete j3982:; quit;
