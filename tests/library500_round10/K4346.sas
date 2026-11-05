/* K4346 cache_gate_avoids_unneeded_generation, N=7; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:400 */

data k4346cache; value=7; run;
%macro k4346m;
%if %sysfunc(exist(work.k4346cache)) %then %do; data k4346o; set k4346cache; actual=value; run; %end;
%else %do; %put ERROR: Unexpected cache miss; %end;
%mend; %k4346m; %sysmacdelete k4346m;

data _null_; if 0 then set k4346o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4346 rows=' rows;
else do; set k4346o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND10_PASS=K4346';
else put 'ERROR: ROUND10_FAIL=K4346 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4346:; quit;
