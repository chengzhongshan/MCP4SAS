/* F1823 freq_weighted_cumulative, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1823a; do k=1 to 4; weight=k; output; end; run;
proc freq data=f1823a noprint; tables k / out=f1823b outcum; weight weight; run;
proc sql; create table f1823o as select sum(cum_freq) as actual from f1823b; quit;

data _null_; if 0 then set f1823o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1823 rows=' rows;
else do; set f1823o; if not missing(actual) and abs(actual-(20))<=1e-9*max(1,abs(20)) then put 'ROUND4_PASS=F1823';
else put 'ERROR: ROUND4_FAIL=F1823 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1823:; quit;
