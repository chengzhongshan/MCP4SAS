/* K4298 expression_median_by_gene, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data k4298a; do gene=1 to 2; do sample=1 to 2*9+1; expression=sample*gene; output; end; end; run;
proc summary data=k4298a nway; class gene; var expression; output out=k4298b median=med; run;
proc sql; create table k4298o as select sum(med) as actual from k4298b; quit;

data _null_; if 0 then set k4298o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4298 rows=' rows;
else do; set k4298o; if not missing(actual) and abs(actual-(30))<=1e-9*max(1,abs(30)) then put 'ROUND10_PASS=K4298';
else put 'ERROR: ROUND10_FAIL=K4298 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4298:; quit;
