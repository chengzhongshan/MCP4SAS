/* B3179 freq_order_frequency, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:94 */

data b3179a; do k=1 to 10; do j=1 to 10-k+1; output; end; end; run;
proc freq data=b3179a order=freq noprint; tables k / out=b3179b; run;
data b3179o; set b3179b; if _n_=1; actual=k+count; run;

data _null_; if 0 then set b3179o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3179 rows=' rows;
else do; set b3179o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND7_PASS=B3179';
else put 'ERROR: ROUND7_FAIL=B3179 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3179:; quit;
