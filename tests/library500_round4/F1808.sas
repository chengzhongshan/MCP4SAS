/* F1808 freq_row_percent, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1808a; do grp=1 to 2; do k=1 to 9; output; end; end; run;
proc freq data=f1808a noprint; tables grp*k / out=f1808b outpct; run;
proc sql; create table f1808o as select max(pct_row) as actual from f1808b; quit;

data _null_; if 0 then set f1808o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1808 rows=' rows;
else do; set f1808o; if not missing(actual) and abs(actual-(11.1111111111111))<=1e-9*max(1,abs(11.1111111111111)) then put 'ROUND4_PASS=F1808';
else put 'ERROR: ROUND4_FAIL=F1808 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1808:; quit;
