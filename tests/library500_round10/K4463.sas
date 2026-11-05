/* K4463 macro_prxchange_greedy_replacement, N=4; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4463v=ABC4;
%let k4463changed=%sysfunc(prxchange(s/ABC.*/Z/,-1,&k4463v));
data k4463o; actual=(symget('k4463changed')='Z'); run; %symdel k4463v k4463changed;

data _null_; if 0 then set k4463o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4463 rows=' rows;
else do; set k4463o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND10_PASS=K4463';
else put 'ERROR: ROUND10_FAIL=K4463 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4463:; quit;
