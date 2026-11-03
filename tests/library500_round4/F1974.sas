/* F1974 failure_append_type_mismatch, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:19 */

data f1974a; value=5; run;
data f1974b; length value $12; value='5'; run;
proc append base=f1974a data=f1974b; run;

proc datasets library=work nolist; delete f1974:; quit;
