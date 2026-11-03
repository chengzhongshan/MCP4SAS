/* J3988 failure_princomp_character_analysis, N=9; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3988a; length text $12; text='9'; run;
proc princomp data=j3988a noprint; var text; run;

proc datasets library=work nolist; delete j3988:; quit;
