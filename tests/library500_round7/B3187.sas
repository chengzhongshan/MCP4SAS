/* B3187 freq_missing_denominator, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:94 */

data b3187a; do k=1 to 8; output; end; k=.; output; output; run;
proc freq data=b3187a noprint; tables k / missing out=b3187b; run;
data b3187o; set b3187b; if missing(k); actual=percent; run;

data _null_; if 0 then set b3187o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3187 rows=' rows;
else do; set b3187o; if not missing(actual) and abs(actual-(20))<=1e-9*max(1,abs(20)) then put 'ROUND7_PASS=B3187';
else put 'ERROR: ROUND7_FAIL=B3187 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3187:; quit;
