/* R509 sql_count_distinct, N=10; source: SAS-Useful-Codes/Macros/GTEx_eQTL_genes_scatterplot.sas:228 */

data r509a; do k=1 to 10; output; output; end; run;
proc sql; create table r509o as select count(distinct k) as actual from r509a; quit;

data _null_; if 0 then set r509o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R509 rows=' rows;
else do; set r509o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND2_PASS=R509';
else put 'ERROR: ROUND2_FAIL=R509 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r509:; quit;
