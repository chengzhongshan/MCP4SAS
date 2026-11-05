/* K4299 expression_median_by_gene, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data k4299a; do gene=1 to 2; do sample=1 to 2*10+1; expression=sample*gene; output; end; end; run;
proc summary data=k4299a nway; class gene; var expression; output out=k4299b median=med; run;
proc sql; create table k4299o as select sum(med) as actual from k4299b; quit;

data _null_; if 0 then set k4299o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4299 rows=' rows;
else do; set k4299o; if not missing(actual) and abs(actual-(33))<=1e-9*max(1,abs(33)) then put 'ROUND10_PASS=K4299';
else put 'ERROR: ROUND10_FAIL=K4299 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4299:; quit;
