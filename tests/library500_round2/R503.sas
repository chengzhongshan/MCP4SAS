/* R503 sql_count_distinct, N=4; source: SAS-Useful-Codes/Macros/GTEx_eQTL_genes_scatterplot.sas:228 */

data r503a; do k=1 to 4; output; output; end; run;
proc sql; create table r503o as select count(distinct k) as actual from r503a; quit;

data _null_; if 0 then set r503o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R503 rows=' rows;
else do; set r503o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND2_PASS=R503';
else put 'ERROR: ROUND2_FAIL=R503 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r503:; quit;
