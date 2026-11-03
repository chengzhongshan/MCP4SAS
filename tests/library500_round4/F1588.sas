/* F1588 means_special_missing_counts, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1588a; do x=0 to 9; output; end; x=.A; output; x=.Z; output; run;
proc means data=f1588a noprint; var x; output out=f1588b n=valid nmiss=absent; run;
data f1588o; set f1588b; actual=10*valid+absent; run;

data _null_; if 0 then set f1588o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1588 rows=' rows;
else do; set f1588o; if not missing(actual) and abs(actual-(102))<=1e-9*max(1,abs(102)) then put 'ROUND4_PASS=F1588';
else put 'ERROR: ROUND4_FAIL=F1588 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1588:; quit;
