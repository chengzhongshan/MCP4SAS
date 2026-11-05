/* K4270 matrix_selected_gene_checksum, N=11; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:400 */

data k4270a; length gene $12; array expr{*} v1-v11; do g=1 to 3; gene=cats('gene',g); do j=1 to dim(expr); expr{j}=g*j; end; output; end; drop j g; run;
data k4270b; set k4270a(where=(gene='gene2')); array expr{*} v1-v11; do sample=1 to dim(expr); value=expr{sample}; output; end; keep sample value; run;
proc sql; create table k4270o as select sum(value) as actual from k4270b; quit;

data _null_; if 0 then set k4270o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4270 rows=' rows;
else do; set k4270o; if not missing(actual) and abs(actual-(132))<=1e-9*max(1,abs(132)) then put 'ROUND10_PASS=K4270';
else put 'ERROR: ROUND10_FAIL=K4270 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4270:; quit;
