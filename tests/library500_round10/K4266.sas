/* K4266 matrix_selected_gene_checksum, N=7; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:400 */

data k4266a; length gene $12; array expr{*} v1-v7; do g=1 to 3; gene=cats('gene',g); do j=1 to dim(expr); expr{j}=g*j; end; output; end; drop j g; run;
data k4266b; set k4266a(where=(gene='gene2')); array expr{*} v1-v7; do sample=1 to dim(expr); value=expr{sample}; output; end; keep sample value; run;
proc sql; create table k4266o as select sum(value) as actual from k4266b; quit;

data _null_; if 0 then set k4266o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4266 rows=' rows;
else do; set k4266o; if not missing(actual) and abs(actual-(56))<=1e-9*max(1,abs(56)) then put 'ROUND10_PASS=K4266';
else put 'ERROR: ROUND10_FAIL=K4266 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4266:; quit;
