/* K4280 matrix_prefix_excludes_numeric_metadata, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data k4280o; metadata=100000; array expr{*} v1-v11; do j=1 to dim(expr); expr{j}=j; end; actual=sum(of v:); run;

data _null_; if 0 then set k4280o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4280 rows=' rows;
else do; set k4280o; if not missing(actual) and abs(actual-(66))<=1e-9*max(1,abs(66)) then put 'ROUND10_PASS=K4280';
else put 'ERROR: ROUND10_FAIL=K4280 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4280:; quit;
