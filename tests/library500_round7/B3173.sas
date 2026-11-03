/* B3173 freq_order_frequency, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:94 */

data b3173a; do k=1 to 4; do j=1 to 4-k+1; output; end; end; run;
proc freq data=b3173a order=freq noprint; tables k / out=b3173b; run;
data b3173o; set b3173b; if _n_=1; actual=k+count; run;

data _null_; if 0 then set b3173o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3173 rows=' rows;
else do; set b3173o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND7_PASS=B3173';
else put 'ERROR: ROUND7_FAIL=B3173 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3173:; quit;
