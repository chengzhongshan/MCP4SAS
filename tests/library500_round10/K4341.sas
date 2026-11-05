/* K4341 cache_gate_avoids_unneeded_generation, N=2; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:400 */

data k4341cache; value=2; run;
%macro k4341m;
%if %sysfunc(exist(work.k4341cache)) %then %do; data k4341o; set k4341cache; actual=value; run; %end;
%else %do; %put ERROR: Unexpected cache miss; %end;
%mend; %k4341m; %sysmacdelete k4341m;

data _null_; if 0 then set k4341o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4341 rows=' rows;
else do; set k4341o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND10_PASS=K4341';
else put 'ERROR: ROUND10_FAIL=K4341 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4341:; quit;
