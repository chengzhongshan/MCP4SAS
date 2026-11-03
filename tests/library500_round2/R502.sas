/* R502 sql_count_distinct, N=3; source: SAS-Useful-Codes/Macros/GTEx_eQTL_genes_scatterplot.sas:228 */

data r502a; do k=1 to 3; output; output; end; run;
proc sql; create table r502o as select count(distinct k) as actual from r502a; quit;

data _null_; if 0 then set r502o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R502 rows=' rows;
else do; set r502o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND2_PASS=R502';
else put 'ERROR: ROUND2_FAIL=R502 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r502:; quit;
