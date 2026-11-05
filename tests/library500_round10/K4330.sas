/* K4330 phenotype_filter_before_aggregate, N=11; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:198 */

data k4330a; do sample=1 to 11; sex='F'; expression=sample; output; sex='M'; expression=1000+sample; output; end; run;
proc means data=k4330a noprint; where sex='F'; var expression; output out=k4330o mean=actual; run;

data _null_; if 0 then set k4330o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4330 rows=' rows;
else do; set k4330o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND10_PASS=K4330';
else put 'ERROR: ROUND10_FAIL=K4330 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4330:; quit;
