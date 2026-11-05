/* K4277 matrix_prefix_excludes_numeric_metadata, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data k4277o; metadata=100000; array expr{*} v1-v8; do j=1 to dim(expr); expr{j}=j; end; actual=sum(of v:); run;

data _null_; if 0 then set k4277o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4277 rows=' rows;
else do; set k4277o; if not missing(actual) and abs(actual-(36))<=1e-9*max(1,abs(36)) then put 'ROUND10_PASS=K4277';
else put 'ERROR: ROUND10_FAIL=K4277 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4277:; quit;
