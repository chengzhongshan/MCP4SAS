/* F1977 failure_append_type_mismatch, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:19 */

data f1977a; value=8; run;
data f1977b; length value $12; value='8'; run;
proc append base=f1977a data=f1977b; run;

proc datasets library=work nolist; delete f1977:; quit;
