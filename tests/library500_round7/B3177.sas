/* B3177 freq_order_frequency, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:94 */

data b3177a; do k=1 to 8; do j=1 to 8-k+1; output; end; end; run;
proc freq data=b3177a order=freq noprint; tables k / out=b3177b; run;
data b3177o; set b3177b; if _n_=1; actual=k+count; run;

data _null_; if 0 then set b3177o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3177 rows=' rows;
else do; set b3177o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND7_PASS=B3177';
else put 'ERROR: ROUND7_FAIL=B3177 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3177:; quit;
