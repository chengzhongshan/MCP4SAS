/* R506 sql_count_distinct, N=7; source: SAS-Useful-Codes/Macros/GTEx_eQTL_genes_scatterplot.sas:228 */

data r506a; do k=1 to 7; output; output; end; run;
proc sql; create table r506o as select count(distinct k) as actual from r506a; quit;

data _null_; if 0 then set r506o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R506 rows=' rows;
else do; set r506o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND2_PASS=R506';
else put 'ERROR: ROUND2_FAIL=R506 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r506:; quit;
