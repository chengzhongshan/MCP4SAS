/* J3987 failure_princomp_character_analysis, N=8; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3987a; length text $12; text='8'; run;
proc princomp data=j3987a noprint; var text; run;

proc datasets library=work nolist; delete j3987:; quit;
