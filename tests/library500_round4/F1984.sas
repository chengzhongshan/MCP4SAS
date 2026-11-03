/* F1984 failure_means_missing_variable, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1984a; do x=1 to 5; output; end; run;
proc means data=f1984a; var f1984absent; run;

proc datasets library=work nolist; delete f1984:; quit;
