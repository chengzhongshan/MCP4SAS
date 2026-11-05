/* K4322 phenotype_filter_before_aggregate, N=3; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:198 */

data k4322a; do sample=1 to 3; sex='F'; expression=sample; output; sex='M'; expression=1000+sample; output; end; run;
proc means data=k4322a noprint; where sex='F'; var expression; output out=k4322o mean=actual; run;

data _null_; if 0 then set k4322o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4322 rows=' rows;
else do; set k4322o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND10_PASS=K4322';
else put 'ERROR: ROUND10_FAIL=K4322 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4322:; quit;
