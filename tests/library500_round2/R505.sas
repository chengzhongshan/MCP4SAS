/* R505 sql_count_distinct, N=6; source: SAS-Useful-Codes/Macros/GTEx_eQTL_genes_scatterplot.sas:228 */

data r505a; do k=1 to 6; output; output; end; run;
proc sql; create table r505o as select count(distinct k) as actual from r505a; quit;

data _null_; if 0 then set r505o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R505 rows=' rows;
else do; set r505o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND2_PASS=R505';
else put 'ERROR: ROUND2_FAIL=R505 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r505:; quit;
