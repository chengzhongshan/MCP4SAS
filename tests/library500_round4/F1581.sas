/* F1581 means_special_missing_counts, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1581a; do x=0 to 2; output; end; x=.A; output; x=.Z; output; run;
proc means data=f1581a noprint; var x; output out=f1581b n=valid nmiss=absent; run;
data f1581o; set f1581b; actual=10*valid+absent; run;

data _null_; if 0 then set f1581o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1581 rows=' rows;
else do; set f1581o; if not missing(actual) and abs(actual-(32))<=1e-9*max(1,abs(32)) then put 'ROUND4_PASS=F1581';
else put 'ERROR: ROUND4_FAIL=F1581 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1581:; quit;
