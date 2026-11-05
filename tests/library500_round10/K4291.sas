/* K4291 expression_median_by_gene, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data k4291a; do gene=1 to 2; do sample=1 to 2*2+1; expression=sample*gene; output; end; end; run;
proc summary data=k4291a nway; class gene; var expression; output out=k4291b median=med; run;
proc sql; create table k4291o as select sum(med) as actual from k4291b; quit;

data _null_; if 0 then set k4291o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4291 rows=' rows;
else do; set k4291o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND10_PASS=K4291';
else put 'ERROR: ROUND10_FAIL=K4291 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4291:; quit;
