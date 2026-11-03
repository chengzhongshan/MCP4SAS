/* F1978 failure_append_type_mismatch, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:19 */

data f1978a; value=9; run;
data f1978b; length value $12; value='9'; run;
proc append base=f1978a data=f1978b; run;

proc datasets library=work nolist; delete f1978:; quit;
