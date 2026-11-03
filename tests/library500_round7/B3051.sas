/* B3051 do_continue_filter, N=2; source: SAS Macro Programming Made Easy, Second Edition.txt:2334 */

data b3051o; actual=0; do x=1 to 2*2; if mod(x,2)=1 then continue; actual=actual+x; end; run;

data _null_; if 0 then set b3051o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3051 rows=' rows;
else do; set b3051o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND7_PASS=B3051';
else put 'ERROR: ROUND7_FAIL=B3051 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3051:; quit;
