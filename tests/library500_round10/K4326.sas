/* K4326 phenotype_filter_before_aggregate, N=7; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:198 */

data k4326a; do sample=1 to 7; sex='F'; expression=sample; output; sex='M'; expression=1000+sample; output; end; run;
proc means data=k4326a noprint; where sex='F'; var expression; output out=k4326o mean=actual; run;

data _null_; if 0 then set k4326o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4326 rows=' rows;
else do; set k4326o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND10_PASS=K4326';
else put 'ERROR: ROUND10_FAIL=K4326 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4326:; quit;
