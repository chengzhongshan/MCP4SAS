/* F1801 freq_row_percent, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1801a; do grp=1 to 2; do k=1 to 2; output; end; end; run;
proc freq data=f1801a noprint; tables grp*k / out=f1801b outpct; run;
proc sql; create table f1801o as select max(pct_row) as actual from f1801b; quit;

data _null_; if 0 then set f1801o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1801 rows=' rows;
else do; set f1801o; if not missing(actual) and abs(actual-(50))<=1e-9*max(1,abs(50)) then put 'ROUND4_PASS=F1801';
else put 'ERROR: ROUND4_FAIL=F1801 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1801:; quit;
