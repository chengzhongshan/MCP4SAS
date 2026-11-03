/* F1804 freq_row_percent, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1804a; do grp=1 to 2; do k=1 to 5; output; end; end; run;
proc freq data=f1804a noprint; tables grp*k / out=f1804b outpct; run;
proc sql; create table f1804o as select max(pct_row) as actual from f1804b; quit;

data _null_; if 0 then set f1804o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1804 rows=' rows;
else do; set f1804o; if not missing(actual) and abs(actual-(20))<=1e-9*max(1,abs(20)) then put 'ROUND4_PASS=F1804';
else put 'ERROR: ROUND4_FAIL=F1804 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1804:; quit;
