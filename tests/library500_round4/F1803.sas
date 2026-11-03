/* F1803 freq_row_percent, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1803a; do grp=1 to 2; do k=1 to 4; output; end; end; run;
proc freq data=f1803a noprint; tables grp*k / out=f1803b outpct; run;
proc sql; create table f1803o as select max(pct_row) as actual from f1803b; quit;

data _null_; if 0 then set f1803o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1803 rows=' rows;
else do; set f1803o; if not missing(actual) and abs(actual-(25))<=1e-9*max(1,abs(25)) then put 'ROUND4_PASS=F1803';
else put 'ERROR: ROUND4_FAIL=F1803 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1803:; quit;
