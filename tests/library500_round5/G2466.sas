/* G2466 failure_set_type_conflict, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:1 */

data g2466a; value=7; run;
data g2466b; length value $12; value='7'; run;
data g2466c; set g2466a g2466b; run;

proc datasets library=work nolist; delete g2466:; quit;
