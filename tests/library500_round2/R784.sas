/* R784 summary_weighted, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data r784a; do x=1 to 5; weight=x; output; end; run;
proc summary data=r784a; var x; weight weight; output out=r784b mean=average; run;
data r784o; set r784b; actual=average; run;

data _null_; if 0 then set r784o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R784 rows=' rows;
else do; set r784o; if not missing(actual) and abs(actual-(3.66666666666667))<=1e-10*max(1,abs(3.66666666666667)) then put 'ROUND2_PASS=R784';
else put 'ERROR: ROUND2_FAIL=R784 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r784:; quit;
