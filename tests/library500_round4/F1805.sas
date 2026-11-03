/* F1805 freq_row_percent, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1805a; do grp=1 to 2; do k=1 to 6; output; end; end; run;
proc freq data=f1805a noprint; tables grp*k / out=f1805b outpct; run;
proc sql; create table f1805o as select max(pct_row) as actual from f1805b; quit;

data _null_; if 0 then set f1805o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1805 rows=' rows;
else do; set f1805o; if not missing(actual) and abs(actual-(16.6666666666667))<=1e-9*max(1,abs(16.6666666666667)) then put 'ROUND4_PASS=F1805';
else put 'ERROR: ROUND4_FAIL=F1805 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1805:; quit;
