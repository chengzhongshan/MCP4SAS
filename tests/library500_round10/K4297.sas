/* K4297 expression_median_by_gene, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data k4297a; do gene=1 to 2; do sample=1 to 2*8+1; expression=sample*gene; output; end; end; run;
proc summary data=k4297a nway; class gene; var expression; output out=k4297b median=med; run;
proc sql; create table k4297o as select sum(med) as actual from k4297b; quit;

data _null_; if 0 then set k4297o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4297 rows=' rows;
else do; set k4297o; if not missing(actual) and abs(actual-(27))<=1e-9*max(1,abs(27)) then put 'ROUND10_PASS=K4297';
else put 'ERROR: ROUND10_FAIL=K4297 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4297:; quit;
