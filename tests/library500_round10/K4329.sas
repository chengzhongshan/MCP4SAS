/* K4329 phenotype_filter_before_aggregate, N=10; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:198 */

data k4329a; do sample=1 to 10; sex='F'; expression=sample; output; sex='M'; expression=1000+sample; output; end; run;
proc means data=k4329a noprint; where sex='F'; var expression; output out=k4329o mean=actual; run;

data _null_; if 0 then set k4329o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4329 rows=' rows;
else do; set k4329o; if not missing(actual) and abs(actual-(5.5))<=1e-9*max(1,abs(5.5)) then put 'ROUND10_PASS=K4329';
else put 'ERROR: ROUND10_FAIL=K4329 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4329:; quit;
