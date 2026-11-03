/* R510 sql_count_distinct, N=11; source: SAS-Useful-Codes/Macros/GTEx_eQTL_genes_scatterplot.sas:228 */

data r510a; do k=1 to 11; output; output; end; run;
proc sql; create table r510o as select count(distinct k) as actual from r510a; quit;

data _null_; if 0 then set r510o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R510 rows=' rows;
else do; set r510o; if not missing(actual) and abs(actual-(11))<=1e-10*max(1,abs(11)) then put 'ROUND2_PASS=R510';
else put 'ERROR: ROUND2_FAIL=R510 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r510:; quit;
