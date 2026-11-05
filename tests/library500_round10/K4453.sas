/* K4453 macro_prx_unquoted_greedy_tail, N=4; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4453v=ABC4;
%let k4453found=%sysfunc(prxmatch(/ABC.*/,&k4453v));
data k4453o; actual=&k4453found; run; %symdel k4453v k4453found;

data _null_; if 0 then set k4453o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4453 rows=' rows;
else do; set k4453o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND10_PASS=K4453';
else put 'ERROR: ROUND10_FAIL=K4453 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4453:; quit;
