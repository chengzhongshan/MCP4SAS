/* B3056 do_continue_filter, N=7; source: SAS Macro Programming Made Easy, Second Edition.txt:2334 */

data b3056o; actual=0; do x=1 to 2*7; if mod(x,2)=1 then continue; actual=actual+x; end; run;

data _null_; if 0 then set b3056o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3056 rows=' rows;
else do; set b3056o; if not missing(actual) and abs(actual-(56))<=1e-9*max(1,abs(56)) then put 'ROUND7_PASS=B3056';
else put 'ERROR: ROUND7_FAIL=B3056 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3056:; quit;
