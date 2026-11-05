/* K4271 matrix_prefix_excludes_numeric_metadata, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data k4271o; metadata=100000; array expr{*} v1-v2; do j=1 to dim(expr); expr{j}=j; end; actual=sum(of v:); run;

data _null_; if 0 then set k4271o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4271 rows=' rows;
else do; set k4271o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND10_PASS=K4271';
else put 'ERROR: ROUND10_FAIL=K4271 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4271:; quit;
