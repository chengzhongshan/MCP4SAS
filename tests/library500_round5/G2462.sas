/* G2462 failure_set_type_conflict, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:1 */

data g2462a; value=3; run;
data g2462b; length value $12; value='3'; run;
data g2462c; set g2462a g2462b; run;

proc datasets library=work nolist; delete g2462:; quit;
