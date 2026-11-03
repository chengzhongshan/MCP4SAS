/* F1830 freq_weighted_cumulative, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1830a; do k=1 to 11; weight=k; output; end; run;
proc freq data=f1830a noprint; tables k / out=f1830b outcum; weight weight; run;
proc sql; create table f1830o as select sum(cum_freq) as actual from f1830b; quit;

data _null_; if 0 then set f1830o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1830 rows=' rows;
else do; set f1830o; if not missing(actual) and abs(actual-(286))<=1e-9*max(1,abs(286)) then put 'ROUND4_PASS=F1830';
else put 'ERROR: ROUND4_FAIL=F1830 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1830:; quit;
