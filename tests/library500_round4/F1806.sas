/* F1806 freq_row_percent, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1806a; do grp=1 to 2; do k=1 to 7; output; end; end; run;
proc freq data=f1806a noprint; tables grp*k / out=f1806b outpct; run;
proc sql; create table f1806o as select max(pct_row) as actual from f1806b; quit;

data _null_; if 0 then set f1806o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1806 rows=' rows;
else do; set f1806o; if not missing(actual) and abs(actual-(14.2857142857143))<=1e-9*max(1,abs(14.2857142857143)) then put 'ROUND4_PASS=F1806';
else put 'ERROR: ROUND4_FAIL=F1806 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1806:; quit;
