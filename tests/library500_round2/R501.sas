/* R501 sql_count_distinct, N=2; source: SAS-Useful-Codes/Macros/GTEx_eQTL_genes_scatterplot.sas:228 */

data r501a; do k=1 to 2; output; output; end; run;
proc sql; create table r501o as select count(distinct k) as actual from r501a; quit;

data _null_; if 0 then set r501o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R501 rows=' rows;
else do; set r501o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND2_PASS=R501';
else put 'ERROR: ROUND2_FAIL=R501 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r501:; quit;
