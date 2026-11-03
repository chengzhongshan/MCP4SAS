/* G2465 failure_set_type_conflict, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:1 */

data g2465a; value=6; run;
data g2465b; length value $12; value='6'; run;
data g2465c; set g2465a g2465b; run;

proc datasets library=work nolist; delete g2465:; quit;
