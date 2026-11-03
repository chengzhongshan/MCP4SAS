/* B3054 do_continue_filter, N=5; source: SAS Macro Programming Made Easy, Second Edition.txt:2334 */

data b3054o; actual=0; do x=1 to 2*5; if mod(x,2)=1 then continue; actual=actual+x; end; run;

data _null_; if 0 then set b3054o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3054 rows=' rows;
else do; set b3054o; if not missing(actual) and abs(actual-(30))<=1e-9*max(1,abs(30)) then put 'ROUND7_PASS=B3054';
else put 'ERROR: ROUND7_FAIL=B3054 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3054:; quit;
