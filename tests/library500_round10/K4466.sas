/* K4466 macro_prxchange_greedy_replacement, N=7; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4466v=ABC7;
%let k4466changed=%sysfunc(prxchange(s/ABC.*/Z/,-1,&k4466v));
data k4466o; actual=(symget('k4466changed')='Z'); run; %symdel k4466v k4466changed;

data _null_; if 0 then set k4466o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4466 rows=' rows;
else do; set k4466o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND10_PASS=K4466';
else put 'ERROR: ROUND10_FAIL=K4466 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4466:; quit;
