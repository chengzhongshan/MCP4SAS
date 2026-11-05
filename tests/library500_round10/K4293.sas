/* K4293 expression_median_by_gene, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data k4293a; do gene=1 to 2; do sample=1 to 2*4+1; expression=sample*gene; output; end; end; run;
proc summary data=k4293a nway; class gene; var expression; output out=k4293b median=med; run;
proc sql; create table k4293o as select sum(med) as actual from k4293b; quit;

data _null_; if 0 then set k4293o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4293 rows=' rows;
else do; set k4293o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND10_PASS=K4293';
else put 'ERROR: ROUND10_FAIL=K4293 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4293:; quit;
