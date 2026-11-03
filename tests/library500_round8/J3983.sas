/* J3983 failure_princomp_character_analysis, N=4; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3983a; length text $12; text='4'; run;
proc princomp data=j3983a noprint; var text; run;

proc datasets library=work nolist; delete j3983:; quit;
