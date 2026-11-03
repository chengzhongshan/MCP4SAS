/* R508 sql_count_distinct, N=9; source: SAS-Useful-Codes/Macros/GTEx_eQTL_genes_scatterplot.sas:228 */

data r508a; do k=1 to 9; output; output; end; run;
proc sql; create table r508o as select count(distinct k) as actual from r508a; quit;

data _null_; if 0 then set r508o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R508 rows=' rows;
else do; set r508o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND2_PASS=R508';
else put 'ERROR: ROUND2_FAIL=R508 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r508:; quit;
