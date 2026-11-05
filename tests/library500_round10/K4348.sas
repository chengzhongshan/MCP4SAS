/* K4348 cache_gate_avoids_unneeded_generation, N=9; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:400 */

data k4348cache; value=9; run;
%macro k4348m;
%if %sysfunc(exist(work.k4348cache)) %then %do; data k4348o; set k4348cache; actual=value; run; %end;
%else %do; %put ERROR: Unexpected cache miss; %end;
%mend; %k4348m; %sysmacdelete k4348m;

data _null_; if 0 then set k4348o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4348 rows=' rows;
else do; set k4348o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND10_PASS=K4348';
else put 'ERROR: ROUND10_FAIL=K4348 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4348:; quit;
