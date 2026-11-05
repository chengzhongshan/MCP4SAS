/* K4325 phenotype_filter_before_aggregate, N=6; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:198 */

data k4325a; do sample=1 to 6; sex='F'; expression=sample; output; sex='M'; expression=1000+sample; output; end; run;
proc means data=k4325a noprint; where sex='F'; var expression; output out=k4325o mean=actual; run;

data _null_; if 0 then set k4325o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4325 rows=' rows;
else do; set k4325o; if not missing(actual) and abs(actual-(3.5))<=1e-9*max(1,abs(3.5)) then put 'ROUND10_PASS=K4325';
else put 'ERROR: ROUND10_FAIL=K4325 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4325:; quit;
