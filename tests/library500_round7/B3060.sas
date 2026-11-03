/* B3060 do_continue_filter, N=11; source: SAS Macro Programming Made Easy, Second Edition.txt:2334 */

data b3060o; actual=0; do x=1 to 2*11; if mod(x,2)=1 then continue; actual=actual+x; end; run;

data _null_; if 0 then set b3060o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3060 rows=' rows;
else do; set b3060o; if not missing(actual) and abs(actual-(132))<=1e-9*max(1,abs(132)) then put 'ROUND7_PASS=B3060';
else put 'ERROR: ROUND7_FAIL=B3060 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3060:; quit;
