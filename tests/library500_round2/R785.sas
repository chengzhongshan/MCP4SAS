/* R785 summary_weighted, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data r785a; do x=1 to 6; weight=x; output; end; run;
proc summary data=r785a; var x; weight weight; output out=r785b mean=average; run;
data r785o; set r785b; actual=average; run;

data _null_; if 0 then set r785o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R785 rows=' rows;
else do; set r785o; if not missing(actual) and abs(actual-(4.33333333333333))<=1e-10*max(1,abs(4.33333333333333)) then put 'ROUND2_PASS=R785';
else put 'ERROR: ROUND2_FAIL=R785 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r785:; quit;
