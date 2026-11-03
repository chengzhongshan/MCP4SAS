/* R781 summary_weighted, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data r781a; do x=1 to 2; weight=x; output; end; run;
proc summary data=r781a; var x; weight weight; output out=r781b mean=average; run;
data r781o; set r781b; actual=average; run;

data _null_; if 0 then set r781o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R781 rows=' rows;
else do; set r781o; if not missing(actual) and abs(actual-(1.66666666666667))<=1e-10*max(1,abs(1.66666666666667)) then put 'ROUND2_PASS=R781';
else put 'ERROR: ROUND2_FAIL=R781 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r781:; quit;
