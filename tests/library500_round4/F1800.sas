/* F1800 freq_uniform_percent, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1800a; do k=1 to 11; output; end; run;
proc freq data=f1800a noprint; tables k / out=f1800b; run;
proc sql; create table f1800o as select max(percent) as actual from f1800b; quit;

data _null_; if 0 then set f1800o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1800 rows=' rows;
else do; set f1800o; if not missing(actual) and abs(actual-(9.09090909090909))<=1e-9*max(1,abs(9.09090909090909)) then put 'ROUND4_PASS=F1800';
else put 'ERROR: ROUND4_FAIL=F1800 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1800:; quit;
