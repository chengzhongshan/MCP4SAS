/* M4025 symputx_after_run_boundary; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:104 */
data _null_; call symputx('m4025v',35,'G'); run;
data m4025o; actual=&m4025v; run; %symdel m4025v;

data _null_; if 0 then set m4025o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND9_ROWS=M4025 rows=' rows;
else do; set m4025o; if not missing(actual) and abs(actual-(35))<=1e-9*max(1,abs(35)) then put 'ROUND9_PASS=M4025';
else put 'ERROR: ROUND9_FAIL=M4025 actual=' actual; end; stop; run;

proc datasets library=work nolist; delete m4025:; quit;
