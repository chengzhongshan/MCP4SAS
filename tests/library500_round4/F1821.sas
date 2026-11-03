/* F1821 freq_weighted_cumulative, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1821a; do k=1 to 2; weight=k; output; end; run;
proc freq data=f1821a noprint; tables k / out=f1821b outcum; weight weight; run;
proc sql; create table f1821o as select sum(cum_freq) as actual from f1821b; quit;

data _null_; if 0 then set f1821o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1821 rows=' rows;
else do; set f1821o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND4_PASS=F1821';
else put 'ERROR: ROUND4_FAIL=F1821 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1821:; quit;
