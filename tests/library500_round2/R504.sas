/* R504 sql_count_distinct, N=5; source: SAS-Useful-Codes/Macros/GTEx_eQTL_genes_scatterplot.sas:228 */

data r504a; do k=1 to 5; output; output; end; run;
proc sql; create table r504o as select count(distinct k) as actual from r504a; quit;

data _null_; if 0 then set r504o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R504 rows=' rows;
else do; set r504o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND2_PASS=R504';
else put 'ERROR: ROUND2_FAIL=R504 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r504:; quit;
