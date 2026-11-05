/* K4345 cache_gate_avoids_unneeded_generation, N=6; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:400 */

data k4345cache; value=6; run;
%macro k4345m;
%if %sysfunc(exist(work.k4345cache)) %then %do; data k4345o; set k4345cache; actual=value; run; %end;
%else %do; %put ERROR: Unexpected cache miss; %end;
%mend; %k4345m; %sysmacdelete k4345m;

data _null_; if 0 then set k4345o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4345 rows=' rows;
else do; set k4345o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND10_PASS=K4345';
else put 'ERROR: ROUND10_FAIL=K4345 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4345:; quit;
