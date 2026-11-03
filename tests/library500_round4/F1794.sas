/* F1794 freq_uniform_percent, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1794a; do k=1 to 5; output; end; run;
proc freq data=f1794a noprint; tables k / out=f1794b; run;
proc sql; create table f1794o as select max(percent) as actual from f1794b; quit;

data _null_; if 0 then set f1794o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1794 rows=' rows;
else do; set f1794o; if not missing(actual) and abs(actual-(20))<=1e-9*max(1,abs(20)) then put 'ROUND4_PASS=F1794';
else put 'ERROR: ROUND4_FAIL=F1794 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1794:; quit;
