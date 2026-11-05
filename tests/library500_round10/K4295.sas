/* K4295 expression_median_by_gene, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data k4295a; do gene=1 to 2; do sample=1 to 2*6+1; expression=sample*gene; output; end; end; run;
proc summary data=k4295a nway; class gene; var expression; output out=k4295b median=med; run;
proc sql; create table k4295o as select sum(med) as actual from k4295b; quit;

data _null_; if 0 then set k4295o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4295 rows=' rows;
else do; set k4295o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND10_PASS=K4295';
else put 'ERROR: ROUND10_FAIL=K4295 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4295:; quit;
