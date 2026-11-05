/* K4294 expression_median_by_gene, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data k4294a; do gene=1 to 2; do sample=1 to 2*5+1; expression=sample*gene; output; end; end; run;
proc summary data=k4294a nway; class gene; var expression; output out=k4294b median=med; run;
proc sql; create table k4294o as select sum(med) as actual from k4294b; quit;

data _null_; if 0 then set k4294o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4294 rows=' rows;
else do; set k4294o; if not missing(actual) and abs(actual-(18))<=1e-9*max(1,abs(18)) then put 'ROUND10_PASS=K4294';
else put 'ERROR: ROUND10_FAIL=K4294 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4294:; quit;
