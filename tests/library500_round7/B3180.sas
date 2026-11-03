/* B3180 freq_order_frequency, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:94 */

data b3180a; do k=1 to 11; do j=1 to 11-k+1; output; end; end; run;
proc freq data=b3180a order=freq noprint; tables k / out=b3180b; run;
data b3180o; set b3180b; if _n_=1; actual=k+count; run;

data _null_; if 0 then set b3180o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3180 rows=' rows;
else do; set b3180o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND7_PASS=B3180';
else put 'ERROR: ROUND7_FAIL=B3180 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3180:; quit;
