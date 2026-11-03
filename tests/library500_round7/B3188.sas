/* B3188 freq_missing_denominator, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:94 */

data b3188a; do k=1 to 9; output; end; k=.; output; output; run;
proc freq data=b3188a noprint; tables k / missing out=b3188b; run;
data b3188o; set b3188b; if missing(k); actual=percent; run;

data _null_; if 0 then set b3188o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3188 rows=' rows;
else do; set b3188o; if not missing(actual) and abs(actual-(18.1818181818182))<=1e-9*max(1,abs(18.1818181818182)) then put 'ROUND7_PASS=B3188';
else put 'ERROR: ROUND7_FAIL=B3188 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3188:; quit;
