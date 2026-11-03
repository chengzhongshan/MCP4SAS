/* F1980 failure_append_type_mismatch, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:19 */

data f1980a; value=11; run;
data f1980b; length value $12; value='11'; run;
proc append base=f1980a data=f1980b; run;

proc datasets library=work nolist; delete f1980:; quit;
