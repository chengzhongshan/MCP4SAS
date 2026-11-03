/* B3171 freq_order_frequency, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:94 */

data b3171a; do k=1 to 2; do j=1 to 2-k+1; output; end; end; run;
proc freq data=b3171a order=freq noprint; tables k / out=b3171b; run;
data b3171o; set b3171b; if _n_=1; actual=k+count; run;

data _null_; if 0 then set b3171o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3171 rows=' rows;
else do; set b3171o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND7_PASS=B3171';
else put 'ERROR: ROUND7_FAIL=B3171 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3171:; quit;
