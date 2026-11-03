/* B3058 do_continue_filter, N=9; source: SAS Macro Programming Made Easy, Second Edition.txt:2334 */

data b3058o; actual=0; do x=1 to 2*9; if mod(x,2)=1 then continue; actual=actual+x; end; run;

data _null_; if 0 then set b3058o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3058 rows=' rows;
else do; set b3058o; if not missing(actual) and abs(actual-(90))<=1e-9*max(1,abs(90)) then put 'ROUND7_PASS=B3058';
else put 'ERROR: ROUND7_FAIL=B3058 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3058:; quit;
