/* K4452 macro_prx_unquoted_greedy_tail, N=3; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4452v=ABC3;
%let k4452found=%sysfunc(prxmatch(/ABC.*/,&k4452v));
data k4452o; actual=&k4452found; run; %symdel k4452v k4452found;

data _null_; if 0 then set k4452o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4452 rows=' rows;
else do; set k4452o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND10_PASS=K4452';
else put 'ERROR: ROUND10_FAIL=K4452 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4452:; quit;
