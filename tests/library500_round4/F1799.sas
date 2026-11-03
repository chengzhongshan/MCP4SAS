/* F1799 freq_uniform_percent, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1799a; do k=1 to 10; output; end; run;
proc freq data=f1799a noprint; tables k / out=f1799b; run;
proc sql; create table f1799o as select max(percent) as actual from f1799b; quit;

data _null_; if 0 then set f1799o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1799 rows=' rows;
else do; set f1799o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND4_PASS=F1799';
else put 'ERROR: ROUND4_FAIL=F1799 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1799:; quit;
