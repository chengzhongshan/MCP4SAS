/* K4454 macro_prx_unquoted_greedy_tail, N=5; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4454v=ABC5;
%let k4454found=%sysfunc(prxmatch(/ABC.*/,&k4454v));
data k4454o; actual=&k4454found; run; %symdel k4454v k4454found;

data _null_; if 0 then set k4454o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4454 rows=' rows;
else do; set k4454o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND10_PASS=K4454';
else put 'ERROR: ROUND10_FAIL=K4454 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4454:; quit;
