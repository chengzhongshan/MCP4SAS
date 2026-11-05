/* K4465 macro_prxchange_greedy_replacement, N=6; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4465v=ABC6;
%let k4465changed=%sysfunc(prxchange(s/ABC.*/Z/,-1,&k4465v));
data k4465o; actual=(symget('k4465changed')='Z'); run; %symdel k4465v k4465changed;

data _null_; if 0 then set k4465o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4465 rows=' rows;
else do; set k4465o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND10_PASS=K4465';
else put 'ERROR: ROUND10_FAIL=K4465 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4465:; quit;
