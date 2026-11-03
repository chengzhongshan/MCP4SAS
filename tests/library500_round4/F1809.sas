/* F1809 freq_row_percent, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1809a; do grp=1 to 2; do k=1 to 10; output; end; end; run;
proc freq data=f1809a noprint; tables grp*k / out=f1809b outpct; run;
proc sql; create table f1809o as select max(pct_row) as actual from f1809b; quit;

data _null_; if 0 then set f1809o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1809 rows=' rows;
else do; set f1809o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND4_PASS=F1809';
else put 'ERROR: ROUND4_FAIL=F1809 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1809:; quit;
