/* J3984 failure_princomp_character_analysis, N=5; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3984a; length text $12; text='5'; run;
proc princomp data=j3984a noprint; var text; run;

proc datasets library=work nolist; delete j3984:; quit;
