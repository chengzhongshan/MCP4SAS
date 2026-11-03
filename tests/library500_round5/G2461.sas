/* G2461 failure_set_type_conflict, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:1 */

data g2461a; value=2; run;
data g2461b; length value $12; value='2'; run;
data g2461c; set g2461a g2461b; run;

proc datasets library=work nolist; delete g2461:; quit;
