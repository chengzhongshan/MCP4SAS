/* K4276 matrix_prefix_excludes_numeric_metadata, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data k4276o; metadata=100000; array expr{*} v1-v7; do j=1 to dim(expr); expr{j}=j; end; actual=sum(of v:); run;

data _null_; if 0 then set k4276o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4276 rows=' rows;
else do; set k4276o; if not missing(actual) and abs(actual-(28))<=1e-9*max(1,abs(28)) then put 'ROUND10_PASS=K4276';
else put 'ERROR: ROUND10_FAIL=K4276 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4276:; quit;
