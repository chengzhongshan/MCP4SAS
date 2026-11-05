/* K4263 matrix_selected_gene_checksum, N=4; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:400 */

data k4263a; length gene $12; array expr{*} v1-v4; do g=1 to 3; gene=cats('gene',g); do j=1 to dim(expr); expr{j}=g*j; end; output; end; drop j g; run;
data k4263b; set k4263a(where=(gene='gene2')); array expr{*} v1-v4; do sample=1 to dim(expr); value=expr{sample}; output; end; keep sample value; run;
proc sql; create table k4263o as select sum(value) as actual from k4263b; quit;

data _null_; if 0 then set k4263o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4263 rows=' rows;
else do; set k4263o; if not missing(actual) and abs(actual-(20))<=1e-9*max(1,abs(20)) then put 'ROUND10_PASS=K4263';
else put 'ERROR: ROUND10_FAIL=K4263 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4263:; quit;
