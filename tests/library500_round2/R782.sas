/* R782 summary_weighted, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data r782a; do x=1 to 3; weight=x; output; end; run;
proc summary data=r782a; var x; weight weight; output out=r782b mean=average; run;
data r782o; set r782b; actual=average; run;

data _null_; if 0 then set r782o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R782 rows=' rows;
else do; set r782o; if not missing(actual) and abs(actual-(2.33333333333333))<=1e-10*max(1,abs(2.33333333333333)) then put 'ROUND2_PASS=R782';
else put 'ERROR: ROUND2_FAIL=R782 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r782:; quit;
