/* F1575 means_squared_range, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/power analysis for multvar regression.sas:8 */

data f1575a; do x=1 to 6; y=x*x; output; end; run;
proc means data=f1575a noprint; var y; output out=f1575o range=actual; run;

data _null_; if 0 then set f1575o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1575 rows=' rows;
else do; set f1575o; if not missing(actual) and abs(actual-(35))<=1e-9*max(1,abs(35)) then put 'ROUND4_PASS=F1575';
else put 'ERROR: ROUND4_FAIL=F1575 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1575:; quit;
