/* F1972 failure_append_type_mismatch, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro function qscan demo_scan black space separated words with special characters _ in it.sas:19 */

data f1972a; value=3; run;
data f1972b; length value $12; value='3'; run;
proc append base=f1972a data=f1972b; run;

proc datasets library=work nolist; delete f1972:; quit;
