/* B3172 freq_order_frequency, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:94 */

data b3172a; do k=1 to 3; do j=1 to 3-k+1; output; end; end; run;
proc freq data=b3172a order=freq noprint; tables k / out=b3172b; run;
data b3172o; set b3172b; if _n_=1; actual=k+count; run;

data _null_; if 0 then set b3172o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3172 rows=' rows;
else do; set b3172o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND7_PASS=B3172';
else put 'ERROR: ROUND7_FAIL=B3172 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3172:; quit;
