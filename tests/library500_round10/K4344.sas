/* K4344 cache_gate_avoids_unneeded_generation, N=5; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:400 */

data k4344cache; value=5; run;
%macro k4344m;
%if %sysfunc(exist(work.k4344cache)) %then %do; data k4344o; set k4344cache; actual=value; run; %end;
%else %do; %put ERROR: Unexpected cache miss; %end;
%mend; %k4344m; %sysmacdelete k4344m;

data _null_; if 0 then set k4344o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4344 rows=' rows;
else do; set k4344o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND10_PASS=K4344';
else put 'ERROR: ROUND10_FAIL=K4344 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4344:; quit;
