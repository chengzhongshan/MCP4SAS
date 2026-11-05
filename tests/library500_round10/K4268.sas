/* K4268 matrix_selected_gene_checksum, N=9; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:400 */

data k4268a; length gene $12; array expr{*} v1-v9; do g=1 to 3; gene=cats('gene',g); do j=1 to dim(expr); expr{j}=g*j; end; output; end; drop j g; run;
data k4268b; set k4268a(where=(gene='gene2')); array expr{*} v1-v9; do sample=1 to dim(expr); value=expr{sample}; output; end; keep sample value; run;
proc sql; create table k4268o as select sum(value) as actual from k4268b; quit;

data _null_; if 0 then set k4268o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4268 rows=' rows;
else do; set k4268o; if not missing(actual) and abs(actual-(90))<=1e-9*max(1,abs(90)) then put 'ROUND10_PASS=K4268';
else put 'ERROR: ROUND10_FAIL=K4268 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4268:; quit;
