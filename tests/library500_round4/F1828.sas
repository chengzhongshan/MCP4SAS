/* F1828 freq_weighted_cumulative, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1828a; do k=1 to 9; weight=k; output; end; run;
proc freq data=f1828a noprint; tables k / out=f1828b outcum; weight weight; run;
proc sql; create table f1828o as select sum(cum_freq) as actual from f1828b; quit;

data _null_; if 0 then set f1828o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1828 rows=' rows;
else do; set f1828o; if not missing(actual) and abs(actual-(165))<=1e-9*max(1,abs(165)) then put 'ROUND4_PASS=F1828';
else put 'ERROR: ROUND4_FAIL=F1828 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1828:; quit;
