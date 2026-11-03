/* R786 summary_weighted, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data r786a; do x=1 to 7; weight=x; output; end; run;
proc summary data=r786a; var x; weight weight; output out=r786b mean=average; run;
data r786o; set r786b; actual=average; run;

data _null_; if 0 then set r786o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R786 rows=' rows;
else do; set r786o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND2_PASS=R786';
else put 'ERROR: ROUND2_FAIL=R786 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r786:; quit;
