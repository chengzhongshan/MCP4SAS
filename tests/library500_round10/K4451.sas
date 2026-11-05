/* K4451 macro_prx_unquoted_greedy_tail, N=2; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4451v=ABC2;
%let k4451found=%sysfunc(prxmatch(/ABC.*/,&k4451v));
data k4451o; actual=&k4451found; run; %symdel k4451v k4451found;

data _null_; if 0 then set k4451o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4451 rows=' rows;
else do; set k4451o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND10_PASS=K4451';
else put 'ERROR: ROUND10_FAIL=K4451 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4451:; quit;
