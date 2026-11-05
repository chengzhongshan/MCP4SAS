/* K4323 phenotype_filter_before_aggregate, N=4; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:198 */

data k4323a; do sample=1 to 4; sex='F'; expression=sample; output; sex='M'; expression=1000+sample; output; end; run;
proc means data=k4323a noprint; where sex='F'; var expression; output out=k4323o mean=actual; run;

data _null_; if 0 then set k4323o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4323 rows=' rows;
else do; set k4323o; if not missing(actual) and abs(actual-(2.5))<=1e-9*max(1,abs(2.5)) then put 'ROUND10_PASS=K4323';
else put 'ERROR: ROUND10_FAIL=K4323 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4323:; quit;
