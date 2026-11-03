/* R507 sql_count_distinct, N=8; source: SAS-Useful-Codes/Macros/GTEx_eQTL_genes_scatterplot.sas:228 */

data r507a; do k=1 to 8; output; output; end; run;
proc sql; create table r507o as select count(distinct k) as actual from r507a; quit;

data _null_; if 0 then set r507o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R507 rows=' rows;
else do; set r507o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND2_PASS=R507';
else put 'ERROR: ROUND2_FAIL=R507 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r507:; quit;
