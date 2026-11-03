/* F1824 freq_weighted_cumulative, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1824a; do k=1 to 5; weight=k; output; end; run;
proc freq data=f1824a noprint; tables k / out=f1824b outcum; weight weight; run;
proc sql; create table f1824o as select sum(cum_freq) as actual from f1824b; quit;

data _null_; if 0 then set f1824o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1824 rows=' rows;
else do; set f1824o; if not missing(actual) and abs(actual-(35))<=1e-9*max(1,abs(35)) then put 'ROUND4_PASS=F1824';
else put 'ERROR: ROUND4_FAIL=F1824 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1824:; quit;
