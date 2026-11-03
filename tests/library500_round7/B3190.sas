/* B3190 freq_missing_denominator, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:94 */

data b3190a; do k=1 to 11; output; end; k=.; output; output; run;
proc freq data=b3190a noprint; tables k / missing out=b3190b; run;
data b3190o; set b3190b; if missing(k); actual=percent; run;

data _null_; if 0 then set b3190o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3190 rows=' rows;
else do; set b3190o; if not missing(actual) and abs(actual-(15.3846153846154))<=1e-9*max(1,abs(15.3846153846154)) then put 'ROUND7_PASS=B3190';
else put 'ERROR: ROUND7_FAIL=B3190 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3190:; quit;
