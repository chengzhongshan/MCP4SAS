/* G2469 failure_set_type_conflict, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:1 */

data g2469a; value=10; run;
data g2469b; length value $12; value='10'; run;
data g2469c; set g2469a g2469b; run;

proc datasets library=work nolist; delete g2469:; quit;
