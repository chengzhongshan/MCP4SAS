/* K4462 macro_prxchange_greedy_replacement, N=3; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4462v=ABC3;
%let k4462changed=%sysfunc(prxchange(s/ABC.*/Z/,-1,&k4462v));
data k4462o; actual=(symget('k4462changed')='Z'); run; %symdel k4462v k4462changed;

data _null_; if 0 then set k4462o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4462 rows=' rows;
else do; set k4462o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND10_PASS=K4462';
else put 'ERROR: ROUND10_FAIL=K4462 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4462:; quit;
