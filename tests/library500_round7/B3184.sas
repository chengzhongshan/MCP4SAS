/* B3184 freq_missing_denominator, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:94 */

data b3184a; do k=1 to 5; output; end; k=.; output; output; run;
proc freq data=b3184a noprint; tables k / missing out=b3184b; run;
data b3184o; set b3184b; if missing(k); actual=percent; run;

data _null_; if 0 then set b3184o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3184 rows=' rows;
else do; set b3184o; if not missing(actual) and abs(actual-(28.5714285714286))<=1e-9*max(1,abs(28.5714285714286)) then put 'ROUND7_PASS=B3184';
else put 'ERROR: ROUND7_FAIL=B3184 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3184:; quit;
