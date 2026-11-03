/* F1825 freq_weighted_cumulative, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data f1825a; do k=1 to 6; weight=k; output; end; run;
proc freq data=f1825a noprint; tables k / out=f1825b outcum; weight weight; run;
proc sql; create table f1825o as select sum(cum_freq) as actual from f1825b; quit;

data _null_; if 0 then set f1825o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1825 rows=' rows;
else do; set f1825o; if not missing(actual) and abs(actual-(56))<=1e-9*max(1,abs(56)) then put 'ROUND4_PASS=F1825';
else put 'ERROR: ROUND4_FAIL=F1825 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1825:; quit;
