/* K4455 macro_prx_unquoted_greedy_tail, N=6; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4455v=ABC6;
%let k4455found=%sysfunc(prxmatch(/ABC.*/,&k4455v));
data k4455o; actual=&k4455found; run; %symdel k4455v k4455found;

data _null_; if 0 then set k4455o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4455 rows=' rows;
else do; set k4455o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND10_PASS=K4455';
else put 'ERROR: ROUND10_FAIL=K4455 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4455:; quit;
