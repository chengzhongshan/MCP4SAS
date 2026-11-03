/* B3057 do_continue_filter, N=8; source: SAS Macro Programming Made Easy, Second Edition.txt:2334 */

data b3057o; actual=0; do x=1 to 2*8; if mod(x,2)=1 then continue; actual=actual+x; end; run;

data _null_; if 0 then set b3057o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND7_ROWS=B3057 rows=' rows;
else do; set b3057o; if not missing(actual) and abs(actual-(72))<=1e-9*max(1,abs(72)) then put 'ROUND7_PASS=B3057';
else put 'ERROR: ROUND7_FAIL=B3057 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete b3057:; quit;
