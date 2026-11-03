/* B3185 freq_missing_denominator, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:94 */

data b3185a; do k=1 to 6; output; end; k=.; output; output; run;
proc freq data=b3185a noprint; tables k / missing out=b3185b; run;
data b3185o; set b3185b; if missing(k); actual=percent; run;

data _null_; if 0 then set b3185o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3185 rows=' rows;
else do; set b3185o; if not missing(actual) and abs(actual-(25))<=1e-9*max(1,abs(25)) then put 'ROUND7_PASS=B3185';
else put 'ERROR: ROUND7_FAIL=B3185 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3185:; quit;
