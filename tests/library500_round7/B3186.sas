/* B3186 freq_missing_denominator, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:94 */

data b3186a; do k=1 to 7; output; end; k=.; output; output; run;
proc freq data=b3186a noprint; tables k / missing out=b3186b; run;
data b3186o; set b3186b; if missing(k); actual=percent; run;

data _null_; if 0 then set b3186o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3186 rows=' rows;
else do; set b3186o; if not missing(actual) and abs(actual-(22.2222222222222))<=1e-9*max(1,abs(22.2222222222222)) then put 'ROUND7_PASS=B3186';
else put 'ERROR: ROUND7_FAIL=B3186 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3186:; quit;
