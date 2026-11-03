/* F1793 freq_uniform_percent, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1793a; do k=1 to 4; output; end; run;
proc freq data=f1793a noprint; tables k / out=f1793b; run;
proc sql; create table f1793o as select max(percent) as actual from f1793b; quit;

data _null_; if 0 then set f1793o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1793 rows=' rows;
else do; set f1793o; if not missing(actual) and abs(actual-(25))<=1e-9*max(1,abs(25)) then put 'ROUND4_PASS=F1793';
else put 'ERROR: ROUND4_FAIL=F1793 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1793:; quit;
