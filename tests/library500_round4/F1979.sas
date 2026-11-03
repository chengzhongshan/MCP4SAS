/* F1979 failure_append_type_mismatch, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:19 */

data f1979a; value=10; run;
data f1979b; length value $12; value='10'; run;
proc append base=f1979a data=f1979b; run;

proc datasets library=work nolist; delete f1979:; quit;
