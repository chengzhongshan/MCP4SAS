/* F1797 freq_uniform_percent, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1797a; do k=1 to 8; output; end; run;
proc freq data=f1797a noprint; tables k / out=f1797b; run;
proc sql; create table f1797o as select max(percent) as actual from f1797b; quit;

data _null_; if 0 then set f1797o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1797 rows=' rows;
else do; set f1797o; if not missing(actual) and abs(actual-(12.5))<=1e-9*max(1,abs(12.5)) then put 'ROUND4_PASS=F1797';
else put 'ERROR: ROUND4_FAIL=F1797 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1797:; quit;
