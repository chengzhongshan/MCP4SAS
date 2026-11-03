/* B3059 do_continue_filter, N=10; source: SAS Macro Programming Made Easy, Second Edition.txt:2334 */

data b3059o; actual=0; do x=1 to 2*10; if mod(x,2)=1 then continue; actual=actual+x; end; run;

data _null_; if 0 then set b3059o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3059 rows=' rows;
else do; set b3059o; if not missing(actual) and abs(actual-(110))<=1e-9*max(1,abs(110)) then put 'ROUND7_PASS=B3059';
else put 'ERROR: ROUND7_FAIL=B3059 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3059:; quit;
