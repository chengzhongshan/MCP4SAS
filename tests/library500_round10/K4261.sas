/* K4261 matrix_selected_gene_checksum, N=2; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:400 */

data k4261a; length gene $12; array expr{*} v1-v2; do g=1 to 3; gene=cats('gene',g); do j=1 to dim(expr); expr{j}=g*j; end; output; end; drop j g; run;
data k4261b; set k4261a(where=(gene='gene2')); array expr{*} v1-v2; do sample=1 to dim(expr); value=expr{sample}; output; end; keep sample value; run;
proc sql; create table k4261o as select sum(value) as actual from k4261b; quit;

data _null_; if 0 then set k4261o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4261 rows=' rows;
else do; set k4261o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND10_PASS=K4261';
else put 'ERROR: ROUND10_FAIL=K4261 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4261:; quit;
