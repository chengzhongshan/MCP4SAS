/* F1976 failure_append_type_mismatch, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:19 */

data f1976a; value=7; run;
data f1976b; length value $12; value='7'; run;
proc append base=f1976a data=f1976b; run;

proc datasets library=work nolist; delete f1976:; quit;
