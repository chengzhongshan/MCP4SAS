/* K4460 macro_prx_unquoted_greedy_tail, N=11; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4460v=ABC11;
%let k4460found=%sysfunc(prxmatch(/ABC.*/,&k4460v));
data k4460o; actual=&k4460found; run; %symdel k4460v k4460found;

data _null_; if 0 then set k4460o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4460 rows=' rows;
else do; set k4460o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND10_PASS=K4460';
else put 'ERROR: ROUND10_FAIL=K4460 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4460:; quit;
