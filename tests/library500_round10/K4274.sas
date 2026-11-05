/* K4274 matrix_prefix_excludes_numeric_metadata, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data k4274o; metadata=100000; array expr{*} v1-v5; do j=1 to dim(expr); expr{j}=j; end; actual=sum(of v:); run;

data _null_; if 0 then set k4274o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4274 rows=' rows;
else do; set k4274o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND10_PASS=K4274';
else put 'ERROR: ROUND10_FAIL=K4274 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4274:; quit;
