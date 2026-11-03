/* F1807 freq_row_percent, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1807a; do grp=1 to 2; do k=1 to 8; output; end; end; run;
proc freq data=f1807a noprint; tables grp*k / out=f1807b outpct; run;
proc sql; create table f1807o as select max(pct_row) as actual from f1807b; quit;

data _null_; if 0 then set f1807o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1807 rows=' rows;
else do; set f1807o; if not missing(actual) and abs(actual-(12.5))<=1e-9*max(1,abs(12.5)) then put 'ROUND4_PASS=F1807';
else put 'ERROR: ROUND4_FAIL=F1807 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1807:; quit;
