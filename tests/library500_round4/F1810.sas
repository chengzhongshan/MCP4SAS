/* F1810 freq_row_percent, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1810a; do grp=1 to 2; do k=1 to 11; output; end; end; run;
proc freq data=f1810a noprint; tables grp*k / out=f1810b outpct; run;
proc sql; create table f1810o as select max(pct_row) as actual from f1810b; quit;

data _null_; if 0 then set f1810o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1810 rows=' rows;
else do; set f1810o; if not missing(actual) and abs(actual-(9.09090909090909))<=1e-9*max(1,abs(9.09090909090909)) then put 'ROUND4_PASS=F1810';
else put 'ERROR: ROUND4_FAIL=F1810 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1810:; quit;
