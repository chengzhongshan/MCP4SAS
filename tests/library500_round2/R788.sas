/* R788 summary_weighted, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data r788a; do x=1 to 9; weight=x; output; end; run;
proc summary data=r788a; var x; weight weight; output out=r788b mean=average; run;
data r788o; set r788b; actual=average; run;

data _null_; if 0 then set r788o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R788 rows=' rows;
else do; set r788o; if not missing(actual) and abs(actual-(6.33333333333333))<=1e-10*max(1,abs(6.33333333333333)) then put 'ROUND2_PASS=R788';
else put 'ERROR: ROUND2_FAIL=R788 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r788:; quit;
