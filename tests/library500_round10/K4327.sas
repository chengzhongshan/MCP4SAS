/* K4327 phenotype_filter_before_aggregate, N=8; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:198 */

data k4327a; do sample=1 to 8; sex='F'; expression=sample; output; sex='M'; expression=1000+sample; output; end; run;
proc means data=k4327a noprint; where sex='F'; var expression; output out=k4327o mean=actual; run;

data _null_; if 0 then set k4327o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4327 rows=' rows;
else do; set k4327o; if not missing(actual) and abs(actual-(4.5))<=1e-9*max(1,abs(4.5)) then put 'ROUND10_PASS=K4327';
else put 'ERROR: ROUND10_FAIL=K4327 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4327:; quit;
