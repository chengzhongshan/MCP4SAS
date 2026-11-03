/* J3990 failure_princomp_character_analysis, N=11; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3990a; length text $12; text='11'; run;
proc princomp data=j3990a noprint; var text; run;

proc datasets library=work nolist; delete j3990:; quit;
