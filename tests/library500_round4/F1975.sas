/* F1975 failure_append_type_mismatch, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:19 */

data f1975a; value=6; run;
data f1975b; length value $12; value='6'; run;
proc append base=f1975a data=f1975b; run;

proc datasets library=work nolist; delete f1975:; quit;
