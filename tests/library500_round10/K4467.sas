/* K4467 macro_prxchange_greedy_replacement, N=8; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4467v=ABC8;
%let k4467changed=%sysfunc(prxchange(s/ABC.*/Z/,-1,&k4467v));
data k4467o; actual=(symget('k4467changed')='Z'); run; %symdel k4467v k4467changed;

data _null_; if 0 then set k4467o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4467 rows=' rows;
else do; set k4467o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND10_PASS=K4467';
else put 'ERROR: ROUND10_FAIL=K4467 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4467:; quit;
