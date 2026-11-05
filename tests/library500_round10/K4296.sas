/* K4296 expression_median_by_gene, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data k4296a; do gene=1 to 2; do sample=1 to 2*7+1; expression=sample*gene; output; end; end; run;
proc summary data=k4296a nway; class gene; var expression; output out=k4296b median=med; run;
proc sql; create table k4296o as select sum(med) as actual from k4296b; quit;

data _null_; if 0 then set k4296o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4296 rows=' rows;
else do; set k4296o; if not missing(actual) and abs(actual-(24))<=1e-9*max(1,abs(24)) then put 'ROUND10_PASS=K4296';
else put 'ERROR: ROUND10_FAIL=K4296 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4296:; quit;
