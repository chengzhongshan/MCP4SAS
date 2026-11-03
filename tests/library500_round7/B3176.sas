/* B3176 freq_order_frequency, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:94 */

data b3176a; do k=1 to 7; do j=1 to 7-k+1; output; end; end; run;
proc freq data=b3176a order=freq noprint; tables k / out=b3176b; run;
data b3176o; set b3176b; if _n_=1; actual=k+count; run;

data _null_; if 0 then set b3176o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3176 rows=' rows;
else do; set b3176o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND7_PASS=B3176';
else put 'ERROR: ROUND7_FAIL=B3176 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3176:; quit;
