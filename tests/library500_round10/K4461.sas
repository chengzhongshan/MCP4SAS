/* K4461 macro_prxchange_greedy_replacement, N=2; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4461v=ABC2;
%let k4461changed=%sysfunc(prxchange(s/ABC.*/Z/,-1,&k4461v));
data k4461o; actual=(symget('k4461changed')='Z'); run; %symdel k4461v k4461changed;

data _null_; if 0 then set k4461o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4461 rows=' rows;
else do; set k4461o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND10_PASS=K4461';
else put 'ERROR: ROUND10_FAIL=K4461 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4461:; quit;
