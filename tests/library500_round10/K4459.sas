/* K4459 macro_prx_unquoted_greedy_tail, N=10; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4459v=ABC10;
%let k4459found=%sysfunc(prxmatch(/ABC.*/,&k4459v));
data k4459o; actual=&k4459found; run; %symdel k4459v k4459found;

data _null_; if 0 then set k4459o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4459 rows=' rows;
else do; set k4459o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND10_PASS=K4459';
else put 'ERROR: ROUND10_FAIL=K4459 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4459:; quit;
