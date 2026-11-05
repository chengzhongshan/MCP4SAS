/* K4469 macro_prxchange_greedy_replacement, N=10; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4469v=ABC10;
%let k4469changed=%sysfunc(prxchange(s/ABC.*/Z/,-1,&k4469v));
data k4469o; actual=(symget('k4469changed')='Z'); run; %symdel k4469v k4469changed;

data _null_; if 0 then set k4469o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4469 rows=' rows;
else do; set k4469o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND10_PASS=K4469';
else put 'ERROR: ROUND10_FAIL=K4469 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4469:; quit;
