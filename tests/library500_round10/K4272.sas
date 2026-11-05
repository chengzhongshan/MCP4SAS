/* K4272 matrix_prefix_excludes_numeric_metadata, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data k4272o; metadata=100000; array expr{*} v1-v3; do j=1 to dim(expr); expr{j}=j; end; actual=sum(of v:); run;

data _null_; if 0 then set k4272o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4272 rows=' rows;
else do; set k4272o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND10_PASS=K4272';
else put 'ERROR: ROUND10_FAIL=K4272 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4272:; quit;
