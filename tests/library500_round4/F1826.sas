/* F1826 freq_weighted_cumulative, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1826a; do k=1 to 7; weight=k; output; end; run;
proc freq data=f1826a noprint; tables k / out=f1826b outcum; weight weight; run;
proc sql; create table f1826o as select sum(cum_freq) as actual from f1826b; quit;

data _null_; if 0 then set f1826o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1826 rows=' rows;
else do; set f1826o; if not missing(actual) and abs(actual-(84))<=1e-9*max(1,abs(84)) then put 'ROUND4_PASS=F1826';
else put 'ERROR: ROUND4_FAIL=F1826 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1826:; quit;
