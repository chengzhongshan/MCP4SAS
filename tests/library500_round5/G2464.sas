/* G2464 failure_set_type_conflict, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:1 */

data g2464a; value=5; run;
data g2464b; length value $12; value='5'; run;
data g2464c; set g2464a g2464b; run;

proc datasets library=work nolist; delete g2464:; quit;
