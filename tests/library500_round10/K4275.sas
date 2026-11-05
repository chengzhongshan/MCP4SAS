/* K4275 matrix_prefix_excludes_numeric_metadata, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data k4275o; metadata=100000; array expr{*} v1-v6; do j=1 to dim(expr); expr{j}=j; end; actual=sum(of v:); run;

data _null_; if 0 then set k4275o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4275 rows=' rows;
else do; set k4275o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND10_PASS=K4275';
else put 'ERROR: ROUND10_FAIL=K4275 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4275:; quit;
