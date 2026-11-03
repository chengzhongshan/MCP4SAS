/* B3178 freq_order_frequency, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:94 */

data b3178a; do k=1 to 9; do j=1 to 9-k+1; output; end; end; run;
proc freq data=b3178a order=freq noprint; tables k / out=b3178b; run;
data b3178o; set b3178b; if _n_=1; actual=k+count; run;

data _null_; if 0 then set b3178o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3178 rows=' rows;
else do; set b3178o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND7_PASS=B3178';
else put 'ERROR: ROUND7_FAIL=B3178 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3178:; quit;
