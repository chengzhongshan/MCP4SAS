/* B3181 freq_missing_denominator, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:94 */

data b3181a; do k=1 to 2; output; end; k=.; output; output; run;
proc freq data=b3181a noprint; tables k / missing out=b3181b; run;
data b3181o; set b3181b; if missing(k); actual=percent; run;

data _null_; if 0 then set b3181o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3181 rows=' rows;
else do; set b3181o; if not missing(actual) and abs(actual-(50))<=1e-9*max(1,abs(50)) then put 'ROUND7_PASS=B3181';
else put 'ERROR: ROUND7_FAIL=B3181 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3181:; quit;
