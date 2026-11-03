/* F1971 failure_append_type_mismatch, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:19 */

data f1971a; value=2; run;
data f1971b; length value $12; value='2'; run;
proc append base=f1971a data=f1971b; run;

proc datasets library=work nolist; delete f1971:; quit;
