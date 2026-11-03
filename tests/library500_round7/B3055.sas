/* B3055 do_continue_filter, N=6; source: SAS Macro Programming Made Easy, Second Edition.txt:2334 */

data b3055o; actual=0; do x=1 to 2*6; if mod(x,2)=1 then continue; actual=actual+x; end; run;

data _null_; if 0 then set b3055o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3055 rows=' rows;
else do; set b3055o; if not missing(actual) and abs(actual-(42))<=1e-9*max(1,abs(42)) then put 'ROUND7_PASS=B3055';
else put 'ERROR: ROUND7_FAIL=B3055 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3055:; quit;
