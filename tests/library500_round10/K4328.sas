/* K4328 phenotype_filter_before_aggregate, N=9; source: Analysis of Clinical Trials Using SAS A Practical Guide.txt:198 */

data k4328a; do sample=1 to 9; sex='F'; expression=sample; output; sex='M'; expression=1000+sample; output; end; run;
proc means data=k4328a noprint; where sex='F'; var expression; output out=k4328o mean=actual; run;

data _null_; if 0 then set k4328o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4328 rows=' rows;
else do; set k4328o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND10_PASS=K4328';
else put 'ERROR: ROUND10_FAIL=K4328 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4328:; quit;
