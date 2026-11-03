/* R804 freq_counts, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/ODS output Tables failed with noprint in Proc Freq.sas:6 */

data r804a; do k=1 to 5; do j=1 to k; output; end; end; run;
proc freq data=r804a noprint; tables k / out=r804b; run;
proc sql; create table r804o as select sum(count) as actual from r804b; quit;

data _null_; if 0 then set r804o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R804 rows=' rows;
else do; set r804o; if not missing(actual) and abs(actual-(15))<=1e-10*max(1,abs(15)) then put 'ROUND2_PASS=R804';
else put 'ERROR: ROUND2_FAIL=R804 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r804:; quit;
