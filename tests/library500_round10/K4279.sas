/* K4279 matrix_prefix_excludes_numeric_metadata, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data k4279o; metadata=100000; array expr{*} v1-v10; do j=1 to dim(expr); expr{j}=j; end; actual=sum(of v:); run;

data _null_; if 0 then set k4279o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4279 rows=' rows;
else do; set k4279o; if not missing(actual) and abs(actual-(55))<=1e-9*max(1,abs(55)) then put 'ROUND10_PASS=K4279';
else put 'ERROR: ROUND10_FAIL=K4279 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4279:; quit;
