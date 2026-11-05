/* K4343 cache_gate_avoids_unneeded_generation, N=4; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:400 */

data k4343cache; value=4; run;
%macro k4343m;
%if %sysfunc(exist(work.k4343cache)) %then %do; data k4343o; set k4343cache; actual=value; run; %end;
%else %do; %put ERROR: Unexpected cache miss; %end;
%mend; %k4343m; %sysmacdelete k4343m;

data _null_; if 0 then set k4343o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4343 rows=' rows;
else do; set k4343o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND10_PASS=K4343';
else put 'ERROR: ROUND10_FAIL=K4343 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4343:; quit;
