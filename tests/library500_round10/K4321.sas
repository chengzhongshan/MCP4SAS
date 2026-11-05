/* K4321 phenotype_filter_before_aggregate, N=2; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:198 */

data k4321a; do sample=1 to 2; sex='F'; expression=sample; output; sex='M'; expression=1000+sample; output; end; run;
proc means data=k4321a noprint; where sex='F'; var expression; output out=k4321o mean=actual; run;

data _null_; if 0 then set k4321o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4321 rows=' rows;
else do; set k4321o; if not missing(actual) and abs(actual-(1.5))<=1e-9*max(1,abs(1.5)) then put 'ROUND10_PASS=K4321';
else put 'ERROR: ROUND10_FAIL=K4321 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4321:; quit;
