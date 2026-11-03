/* J3986 failure_princomp_character_analysis, N=7; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3986a; length text $12; text='7'; run;
proc princomp data=j3986a noprint; var text; run;

proc datasets library=work nolist; delete j3986:; quit;
