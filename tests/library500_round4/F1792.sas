/* F1792 freq_uniform_percent, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1792a; do k=1 to 3; output; end; run;
proc freq data=f1792a noprint; tables k / out=f1792b; run;
proc sql; create table f1792o as select max(percent) as actual from f1792b; quit;

data _null_; if 0 then set f1792o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1792 rows=' rows;
else do; set f1792o; if not missing(actual) and abs(actual-(33.3333333333333))<=1e-9*max(1,abs(33.3333333333333)) then put 'ROUND4_PASS=F1792';
else put 'ERROR: ROUND4_FAIL=F1792 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1792:; quit;
