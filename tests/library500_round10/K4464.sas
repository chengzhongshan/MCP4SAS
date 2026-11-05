/* K4464 macro_prxchange_greedy_replacement, N=5; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4464v=ABC5;
%let k4464changed=%sysfunc(prxchange(s/ABC.*/Z/,-1,&k4464v));
data k4464o; actual=(symget('k4464changed')='Z'); run; %symdel k4464v k4464changed;

data _null_; if 0 then set k4464o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4464 rows=' rows;
else do; set k4464o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND10_PASS=K4464';
else put 'ERROR: ROUND10_FAIL=K4464 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4464:; quit;
