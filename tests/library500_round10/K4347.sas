/* K4347 cache_gate_avoids_unneeded_generation, N=8; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:400 */

data k4347cache; value=8; run;
%macro k4347m;
%if %sysfunc(exist(work.k4347cache)) %then %do; data k4347o; set k4347cache; actual=value; run; %end;
%else %do; %put ERROR: Unexpected cache miss; %end;
%mend; %k4347m; %sysmacdelete k4347m;

data _null_; if 0 then set k4347o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4347 rows=' rows;
else do; set k4347o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND10_PASS=K4347';
else put 'ERROR: ROUND10_FAIL=K4347 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4347:; quit;
