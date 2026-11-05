/* K4265 matrix_selected_gene_checksum, N=6; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:400 */

data k4265a; length gene $12; array expr{*} v1-v6; do g=1 to 3; gene=cats('gene',g); do j=1 to dim(expr); expr{j}=g*j; end; output; end; drop j g; run;
data k4265b; set k4265a(where=(gene='gene2')); array expr{*} v1-v6; do sample=1 to dim(expr); value=expr{sample}; output; end; keep sample value; run;
proc sql; create table k4265o as select sum(value) as actual from k4265b; quit;

data _null_; if 0 then set k4265o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4265 rows=' rows;
else do; set k4265o; if not missing(actual) and abs(actual-(42))<=1e-9*max(1,abs(42)) then put 'ROUND10_PASS=K4265';
else put 'ERROR: ROUND10_FAIL=K4265 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4265:; quit;
