/* R787 summary_weighted, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data r787a; do x=1 to 8; weight=x; output; end; run;
proc summary data=r787a; var x; weight weight; output out=r787b mean=average; run;
data r787o; set r787b; actual=average; run;

data _null_; if 0 then set r787o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R787 rows=' rows;
else do; set r787o; if not missing(actual) and abs(actual-(5.66666666666667))<=1e-10*max(1,abs(5.66666666666667)) then put 'ROUND2_PASS=R787';
else put 'ERROR: ROUND2_FAIL=R787 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r787:; quit;
