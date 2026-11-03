/* F1829 freq_weighted_cumulative, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1829a; do k=1 to 10; weight=k; output; end; run;
proc freq data=f1829a noprint; tables k / out=f1829b outcum; weight weight; run;
proc sql; create table f1829o as select sum(cum_freq) as actual from f1829b; quit;

data _null_; if 0 then set f1829o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1829 rows=' rows;
else do; set f1829o; if not missing(actual) and abs(actual-(220))<=1e-9*max(1,abs(220)) then put 'ROUND4_PASS=F1829';
else put 'ERROR: ROUND4_FAIL=F1829 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1829:; quit;
