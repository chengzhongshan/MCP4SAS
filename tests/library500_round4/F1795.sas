/* F1795 freq_uniform_percent, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1795a; do k=1 to 6; output; end; run;
proc freq data=f1795a noprint; tables k / out=f1795b; run;
proc sql; create table f1795o as select max(percent) as actual from f1795b; quit;

data _null_; if 0 then set f1795o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1795 rows=' rows;
else do; set f1795o; if not missing(actual) and abs(actual-(16.6666666666667))<=1e-9*max(1,abs(16.6666666666667)) then put 'ROUND4_PASS=F1795';
else put 'ERROR: ROUND4_FAIL=F1795 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1795:; quit;
