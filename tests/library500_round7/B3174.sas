/* B3174 freq_order_frequency, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:94 */

data b3174a; do k=1 to 5; do j=1 to 5-k+1; output; end; end; run;
proc freq data=b3174a order=freq noprint; tables k / out=b3174b; run;
data b3174o; set b3174b; if _n_=1; actual=k+count; run;

data _null_; if 0 then set b3174o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3174 rows=' rows;
else do; set b3174o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND7_PASS=B3174';
else put 'ERROR: ROUND7_FAIL=B3174 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3174:; quit;
