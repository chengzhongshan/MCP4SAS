/* F1827 freq_weighted_cumulative, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1827a; do k=1 to 8; weight=k; output; end; run;
proc freq data=f1827a noprint; tables k / out=f1827b outcum; weight weight; run;
proc sql; create table f1827o as select sum(cum_freq) as actual from f1827b; quit;

data _null_; if 0 then set f1827o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1827 rows=' rows;
else do; set f1827o; if not missing(actual) and abs(actual-(120))<=1e-9*max(1,abs(120)) then put 'ROUND4_PASS=F1827';
else put 'ERROR: ROUND4_FAIL=F1827 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1827:; quit;
