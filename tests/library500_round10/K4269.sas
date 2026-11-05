/* K4269 matrix_selected_gene_checksum, N=10; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:400 */

data k4269a; length gene $12; array expr{*} v1-v10; do g=1 to 3; gene=cats('gene',g); do j=1 to dim(expr); expr{j}=g*j; end; output; end; drop j g; run;
data k4269b; set k4269a(where=(gene='gene2')); array expr{*} v1-v10; do sample=1 to dim(expr); value=expr{sample}; output; end; keep sample value; run;
proc sql; create table k4269o as select sum(value) as actual from k4269b; quit;

data _null_; if 0 then set k4269o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4269 rows=' rows;
else do; set k4269o; if not missing(actual) and abs(actual-(110))<=1e-9*max(1,abs(110)) then put 'ROUND10_PASS=K4269';
else put 'ERROR: ROUND10_FAIL=K4269 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4269:; quit;
