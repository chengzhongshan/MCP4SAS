/* K4458 macro_prx_unquoted_greedy_tail, N=9; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4458v=ABC9;
%let k4458found=%sysfunc(prxmatch(/ABC.*/,&k4458v));
data k4458o; actual=&k4458found; run; %symdel k4458v k4458found;

data _null_; if 0 then set k4458o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4458 rows=' rows;
else do; set k4458o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND10_PASS=K4458';
else put 'ERROR: ROUND10_FAIL=K4458 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4458:; quit;
