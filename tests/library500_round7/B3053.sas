/* B3053 do_continue_filter, N=4; source: SAS Macro Programming Made Easy, Second Edition.txt:2334 */

data b3053o; actual=0; do x=1 to 2*4; if mod(x,2)=1 then continue; actual=actual+x; end; run;

data _null_; if 0 then set b3053o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3053 rows=' rows;
else do; set b3053o; if not missing(actual) and abs(actual-(20))<=1e-9*max(1,abs(20)) then put 'ROUND7_PASS=B3053';
else put 'ERROR: ROUND7_FAIL=B3053 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3053:; quit;
