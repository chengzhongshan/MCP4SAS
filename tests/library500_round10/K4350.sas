/* K4350 cache_gate_avoids_unneeded_generation, N=11; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:400 */

data k4350cache; value=11; run;
%macro k4350m;
%if %sysfunc(exist(work.k4350cache)) %then %do; data k4350o; set k4350cache; actual=value; run; %end;
%else %do; %put ERROR: Unexpected cache miss; %end;
%mend; %k4350m; %sysmacdelete k4350m;

data _null_; if 0 then set k4350o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4350 rows=' rows;
else do; set k4350o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND10_PASS=K4350';
else put 'ERROR: ROUND10_FAIL=K4350 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4350:; quit;
