/* R790 summary_weighted, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data r790a; do x=1 to 11; weight=x; output; end; run;
proc summary data=r790a; var x; weight weight; output out=r790b mean=average; run;
data r790o; set r790b; actual=average; run;

data _null_; if 0 then set r790o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R790 rows=' rows;
else do; set r790o; if not missing(actual) and abs(actual-(7.66666666666667))<=1e-10*max(1,abs(7.66666666666667)) then put 'ROUND2_PASS=R790';
else put 'ERROR: ROUND2_FAIL=R790 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r790:; quit;
