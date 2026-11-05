/* K4264 matrix_selected_gene_checksum, N=5; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:400 */

data k4264a; length gene $12; array expr{*} v1-v5; do g=1 to 3; gene=cats('gene',g); do j=1 to dim(expr); expr{j}=g*j; end; output; end; drop j g; run;
data k4264b; set k4264a(where=(gene='gene2')); array expr{*} v1-v5; do sample=1 to dim(expr); value=expr{sample}; output; end; keep sample value; run;
proc sql; create table k4264o as select sum(value) as actual from k4264b; quit;

data _null_; if 0 then set k4264o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4264 rows=' rows;
else do; set k4264o; if not missing(actual) and abs(actual-(30))<=1e-9*max(1,abs(30)) then put 'ROUND10_PASS=K4264';
else put 'ERROR: ROUND10_FAIL=K4264 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4264:; quit;
