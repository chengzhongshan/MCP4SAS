/* F1796 freq_uniform_percent, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1796a; do k=1 to 7; output; end; run;
proc freq data=f1796a noprint; tables k / out=f1796b; run;
proc sql; create table f1796o as select max(percent) as actual from f1796b; quit;

data _null_; if 0 then set f1796o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1796 rows=' rows;
else do; set f1796o; if not missing(actual) and abs(actual-(14.2857142857143))<=1e-9*max(1,abs(14.2857142857143)) then put 'ROUND4_PASS=F1796';
else put 'ERROR: ROUND4_FAIL=F1796 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1796:; quit;
