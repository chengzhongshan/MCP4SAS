/* F1802 freq_row_percent, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1802a; do grp=1 to 2; do k=1 to 3; output; end; end; run;
proc freq data=f1802a noprint; tables grp*k / out=f1802b outpct; run;
proc sql; create table f1802o as select max(pct_row) as actual from f1802b; quit;

data _null_; if 0 then set f1802o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1802 rows=' rows;
else do; set f1802o; if not missing(actual) and abs(actual-(33.3333333333333))<=1e-9*max(1,abs(33.3333333333333)) then put 'ROUND4_PASS=F1802';
else put 'ERROR: ROUND4_FAIL=F1802 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1802:; quit;
