/* K4468 macro_prxchange_greedy_replacement, N=9; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4468v=ABC9;
%let k4468changed=%sysfunc(prxchange(s/ABC.*/Z/,-1,&k4468v));
data k4468o; actual=(symget('k4468changed')='Z'); run; %symdel k4468v k4468changed;

data _null_; if 0 then set k4468o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4468 rows=' rows;
else do; set k4468o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND10_PASS=K4468';
else put 'ERROR: ROUND10_FAIL=K4468 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4468:; quit;
