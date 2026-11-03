/* F1822 freq_weighted_cumulative, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1822a; do k=1 to 3; weight=k; output; end; run;
proc freq data=f1822a noprint; tables k / out=f1822b outcum; weight weight; run;
proc sql; create table f1822o as select sum(cum_freq) as actual from f1822b; quit;

data _null_; if 0 then set f1822o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1822 rows=' rows;
else do; set f1822o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND4_PASS=F1822';
else put 'ERROR: ROUND4_FAIL=F1822 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1822:; quit;
