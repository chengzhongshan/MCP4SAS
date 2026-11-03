/* F1582 means_special_missing_counts, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1582a; do x=0 to 3; output; end; x=.A; output; x=.Z; output; run;
proc means data=f1582a noprint; var x; output out=f1582b n=valid nmiss=absent; run;
data f1582o; set f1582b; actual=10*valid+absent; run;

data _null_; if 0 then set f1582o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1582 rows=' rows;
else do; set f1582o; if not missing(actual) and abs(actual-(42))<=1e-9*max(1,abs(42)) then put 'ROUND4_PASS=F1582';
else put 'ERROR: ROUND4_FAIL=F1582 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1582:; quit;
