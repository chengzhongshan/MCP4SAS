/* B3182 freq_missing_denominator, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:94 */

data b3182a; do k=1 to 3; output; end; k=.; output; output; run;
proc freq data=b3182a noprint; tables k / missing out=b3182b; run;
data b3182o; set b3182b; if missing(k); actual=percent; run;

data _null_; if 0 then set b3182o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3182 rows=' rows;
else do; set b3182o; if not missing(actual) and abs(actual-(40))<=1e-9*max(1,abs(40)) then put 'ROUND7_PASS=B3182';
else put 'ERROR: ROUND7_FAIL=B3182 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3182:; quit;
