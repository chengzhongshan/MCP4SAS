/* R789 summary_weighted, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data r789a; do x=1 to 10; weight=x; output; end; run;
proc summary data=r789a; var x; weight weight; output out=r789b mean=average; run;
data r789o; set r789b; actual=average; run;

data _null_; if 0 then set r789o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R789 rows=' rows;
else do; set r789o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND2_PASS=R789';
else put 'ERROR: ROUND2_FAIL=R789 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r789:; quit;
