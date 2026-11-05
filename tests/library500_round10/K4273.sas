/* K4273 matrix_prefix_excludes_numeric_metadata, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data k4273o; metadata=100000; array expr{*} v1-v4; do j=1 to dim(expr); expr{j}=j; end; actual=sum(of v:); run;

data _null_; if 0 then set k4273o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4273 rows=' rows;
else do; set k4273o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND10_PASS=K4273';
else put 'ERROR: ROUND10_FAIL=K4273 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4273:; quit;
