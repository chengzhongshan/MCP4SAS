/* K4254 matrix_filter_before_transpose, N=5; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:400 */

data k4254a; length gene $12; array expr{*} v1-v5; do g=1 to 3; gene=cats('gene',g); do j=1 to dim(expr); expr{j}=g*j; end; output; end; drop j g; run;
data k4254b; set k4254a(where=(gene in ('gene1','gene2'))); array expr{*} v1-v5; do sample=1 to dim(expr); value=expr{sample}; output; end; keep gene sample value; run;
proc sql; create table k4254o as select count(*) as actual from k4254b; quit;

data _null_; if 0 then set k4254o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4254 rows=' rows;
else do; set k4254o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND10_PASS=K4254';
else put 'ERROR: ROUND10_FAIL=K4254 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4254:; quit;
