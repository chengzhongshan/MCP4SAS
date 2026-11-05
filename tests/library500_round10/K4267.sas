/* K4267 matrix_selected_gene_checksum, N=8; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:400 */

data k4267a; length gene $12; array expr{*} v1-v8; do g=1 to 3; gene=cats('gene',g); do j=1 to dim(expr); expr{j}=g*j; end; output; end; drop j g; run;
data k4267b; set k4267a(where=(gene='gene2')); array expr{*} v1-v8; do sample=1 to dim(expr); value=expr{sample}; output; end; keep sample value; run;
proc sql; create table k4267o as select sum(value) as actual from k4267b; quit;

data _null_; if 0 then set k4267o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4267 rows=' rows;
else do; set k4267o; if not missing(actual) and abs(actual-(72))<=1e-9*max(1,abs(72)) then put 'ROUND10_PASS=K4267';
else put 'ERROR: ROUND10_FAIL=K4267 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4267:; quit;
