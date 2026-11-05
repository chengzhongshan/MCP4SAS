/* K4292 expression_median_by_gene, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data k4292a; do gene=1 to 2; do sample=1 to 2*3+1; expression=sample*gene; output; end; end; run;
proc summary data=k4292a nway; class gene; var expression; output out=k4292b median=med; run;
proc sql; create table k4292o as select sum(med) as actual from k4292b; quit;

data _null_; if 0 then set k4292o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4292 rows=' rows;
else do; set k4292o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND10_PASS=K4292';
else put 'ERROR: ROUND10_FAIL=K4292 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4292:; quit;
