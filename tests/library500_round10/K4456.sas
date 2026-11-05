/* K4456 macro_prx_unquoted_greedy_tail, N=7; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4456v=ABC7;
%let k4456found=%sysfunc(prxmatch(/ABC.*/,&k4456v));
data k4456o; actual=&k4456found; run; %symdel k4456v k4456found;

data _null_; if 0 then set k4456o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4456 rows=' rows;
else do; set k4456o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND10_PASS=K4456';
else put 'ERROR: ROUND10_FAIL=K4456 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4456:; quit;
