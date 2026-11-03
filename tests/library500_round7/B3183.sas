/* B3183 freq_missing_denominator, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:94 */

data b3183a; do k=1 to 4; output; end; k=.; output; output; run;
proc freq data=b3183a noprint; tables k / missing out=b3183b; run;
data b3183o; set b3183b; if missing(k); actual=percent; run;

data _null_; if 0 then set b3183o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3183 rows=' rows;
else do; set b3183o; if not missing(actual) and abs(actual-(33.3333333333333))<=1e-9*max(1,abs(33.3333333333333)) then put 'ROUND7_PASS=B3183';
else put 'ERROR: ROUND7_FAIL=B3183 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3183:; quit;
