/* B3175 freq_order_frequency, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:94 */

data b3175a; do k=1 to 6; do j=1 to 6-k+1; output; end; end; run;
proc freq data=b3175a order=freq noprint; tables k / out=b3175b; run;
data b3175o; set b3175b; if _n_=1; actual=k+count; run;

data _null_; if 0 then set b3175o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3175 rows=' rows;
else do; set b3175o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND7_PASS=B3175';
else put 'ERROR: ROUND7_FAIL=B3175 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3175:; quit;
