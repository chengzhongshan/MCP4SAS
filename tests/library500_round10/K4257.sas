/* K4257 matrix_filter_before_transpose, N=8; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:400 */

data k4257a; length gene $12; array expr{*} v1-v8; do g=1 to 3; gene=cats('gene',g); do j=1 to dim(expr); expr{j}=g*j; end; output; end; drop j g; run;
data k4257b; set k4257a(where=(gene in ('gene1','gene2'))); array expr{*} v1-v8; do sample=1 to dim(expr); value=expr{sample}; output; end; keep gene sample value; run;
proc sql; create table k4257o as select count(*) as actual from k4257b; quit;

data _null_; if 0 then set k4257o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4257 rows=' rows;
else do; set k4257o; if not missing(actual) and abs(actual-(16))<=1e-9*max(1,abs(16)) then put 'ROUND10_PASS=K4257';
else put 'ERROR: ROUND10_FAIL=K4257 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4257:; quit;
