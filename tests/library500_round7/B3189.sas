/* B3189 freq_missing_denominator, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:94 */

data b3189a; do k=1 to 10; output; end; k=.; output; output; run;
proc freq data=b3189a noprint; tables k / missing out=b3189b; run;
data b3189o; set b3189b; if missing(k); actual=percent; run;

data _null_; if 0 then set b3189o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3189 rows=' rows;
else do; set b3189o; if not missing(actual) and abs(actual-(16.6666666666667))<=1e-9*max(1,abs(16.6666666666667)) then put 'ROUND7_PASS=B3189';
else put 'ERROR: ROUND7_FAIL=B3189 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3189:; quit;
