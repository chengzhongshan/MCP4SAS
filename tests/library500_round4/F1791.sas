/* F1791 freq_uniform_percent, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1791a; do k=1 to 2; output; end; run;
proc freq data=f1791a noprint; tables k / out=f1791b; run;
proc sql; create table f1791o as select max(percent) as actual from f1791b; quit;

data _null_; if 0 then set f1791o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1791 rows=' rows;
else do; set f1791o; if not missing(actual) and abs(actual-(50))<=1e-9*max(1,abs(50)) then put 'ROUND4_PASS=F1791';
else put 'ERROR: ROUND4_FAIL=F1791 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1791:; quit;
