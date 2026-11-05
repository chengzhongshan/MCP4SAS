/* K4300 expression_median_by_gene, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:52 */

data k4300a; do gene=1 to 2; do sample=1 to 2*11+1; expression=sample*gene; output; end; end; run;
proc summary data=k4300a nway; class gene; var expression; output out=k4300b median=med; run;
proc sql; create table k4300o as select sum(med) as actual from k4300b; quit;

data _null_; if 0 then set k4300o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4300 rows=' rows;
else do; set k4300o; if not missing(actual) and abs(actual-(36))<=1e-9*max(1,abs(36)) then put 'ROUND10_PASS=K4300';
else put 'ERROR: ROUND10_FAIL=K4300 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4300:; quit;
