/* K4470 macro_prxchange_greedy_replacement, N=11; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4470v=ABC11;
%let k4470changed=%sysfunc(prxchange(s/ABC.*/Z/,-1,&k4470v));
data k4470o; actual=(symget('k4470changed')='Z'); run; %symdel k4470v k4470changed;

data _null_; if 0 then set k4470o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4470 rows=' rows;
else do; set k4470o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND10_PASS=K4470';
else put 'ERROR: ROUND10_FAIL=K4470 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4470:; quit;
