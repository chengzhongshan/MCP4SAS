/* K4278 matrix_prefix_excludes_numeric_metadata, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data k4278o; metadata=100000; array expr{*} v1-v9; do j=1 to dim(expr); expr{j}=j; end; actual=sum(of v:); run;

data _null_; if 0 then set k4278o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4278 rows=' rows;
else do; set k4278o; if not missing(actual) and abs(actual-(45))<=1e-9*max(1,abs(45)) then put 'ROUND10_PASS=K4278';
else put 'ERROR: ROUND10_FAIL=K4278 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4278:; quit;
