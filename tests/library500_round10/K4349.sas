/* K4349 cache_gate_avoids_unneeded_generation, N=10; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:400 */

data k4349cache; value=10; run;
%macro k4349m;
%if %sysfunc(exist(work.k4349cache)) %then %do; data k4349o; set k4349cache; actual=value; run; %end;
%else %do; %put ERROR: Unexpected cache miss; %end;
%mend; %k4349m; %sysmacdelete k4349m;

data _null_; if 0 then set k4349o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4349 rows=' rows;
else do; set k4349o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND10_PASS=K4349';
else put 'ERROR: ROUND10_FAIL=K4349 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4349:; quit;
