/* B3052 do_continue_filter, N=3; source: SAS Macro Programming Made Easy, Second Edition.txt:2334 */

data b3052o; actual=0; do x=1 to 2*3; if mod(x,2)=1 then continue; actual=actual+x; end; run;

data _null_; if 0 then set b3052o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3052 rows=' rows;
else do; set b3052o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND7_PASS=B3052';
else put 'ERROR: ROUND7_FAIL=B3052 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3052:; quit;
