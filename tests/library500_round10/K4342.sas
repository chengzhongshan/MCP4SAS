/* K4342 cache_gate_avoids_unneeded_generation, N=3; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:400 */

data k4342cache; value=3; run;
%macro k4342m;
%if %sysfunc(exist(work.k4342cache)) %then %do; data k4342o; set k4342cache; actual=value; run; %end;
%else %do; %put ERROR: Unexpected cache miss; %end;
%mend; %k4342m; %sysmacdelete k4342m;

data _null_; if 0 then set k4342o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4342 rows=' rows;
else do; set k4342o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND10_PASS=K4342';
else put 'ERROR: ROUND10_FAIL=K4342 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4342:; quit;
