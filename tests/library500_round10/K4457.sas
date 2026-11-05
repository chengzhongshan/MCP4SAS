/* K4457 macro_prx_unquoted_greedy_tail, N=8; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4457v=ABC8;
%let k4457found=%sysfunc(prxmatch(/ABC.*/,&k4457v));
data k4457o; actual=&k4457found; run; %symdel k4457v k4457found;

data _null_; if 0 then set k4457o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4457 rows=' rows;
else do; set k4457o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND10_PASS=K4457';
else put 'ERROR: ROUND10_FAIL=K4457 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4457:; quit;
