/* F1982 failure_means_missing_variable, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1982a; do x=1 to 3; output; end; run;
proc means data=f1982a; var f1982absent; run;

proc datasets library=work nolist; delete f1982:; quit;
