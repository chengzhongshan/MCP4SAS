/* K4324 phenotype_filter_before_aggregate, N=5; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:198 */

data k4324a; do sample=1 to 5; sex='F'; expression=sample; output; sex='M'; expression=1000+sample; output; end; run;
proc means data=k4324a noprint; where sex='F'; var expression; output out=k4324o mean=actual; run;

data _null_; if 0 then set k4324o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4324 rows=' rows;
else do; set k4324o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND10_PASS=K4324';
else put 'ERROR: ROUND10_FAIL=K4324 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4324:; quit;
