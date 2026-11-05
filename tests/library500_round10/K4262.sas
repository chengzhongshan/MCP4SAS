/* K4262 matrix_selected_gene_checksum, N=3; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:400 */

data k4262a; length gene $12; array expr{*} v1-v3; do g=1 to 3; gene=cats('gene',g); do j=1 to dim(expr); expr{j}=g*j; end; output; end; drop j g; run;
data k4262b; set k4262a(where=(gene='gene2')); array expr{*} v1-v3; do sample=1 to dim(expr); value=expr{sample}; output; end; keep sample value; run;
proc sql; create table k4262o as select sum(value) as actual from k4262b; quit;

data _null_; if 0 then set k4262o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4262 rows=' rows;
else do; set k4262o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND10_PASS=K4262';
else put 'ERROR: ROUND10_FAIL=K4262 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4262:; quit;
