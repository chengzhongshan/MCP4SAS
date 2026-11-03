/* F1973 failure_append_type_mismatch, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:19 */

data f1973a; value=4; run;
data f1973b; length value $12; value='4'; run;
proc append base=f1973a data=f1973b; run;

proc datasets library=work nolist; delete f1973:; quit;
