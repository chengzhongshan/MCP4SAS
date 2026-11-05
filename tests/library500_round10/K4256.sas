/* K4256 matrix_filter_before_transpose, N=7; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:400 */

data k4256a; length gene $12; array expr{*} v1-v7; do g=1 to 3; gene=cats('gene',g); do j=1 to dim(expr); expr{j}=g*j; end; output; end; drop j g; run;
data k4256b; set k4256a(where=(gene in ('gene1','gene2'))); array expr{*} v1-v7; do sample=1 to dim(expr); value=expr{sample}; output; end; keep gene sample value; run;
proc sql; create table k4256o as select count(*) as actual from k4256b; quit;

data _null_; if 0 then set k4256o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4256 rows=' rows;
else do; set k4256o; if not missing(actual) and abs(actual-(14))<=1e-9*max(1,abs(14)) then put 'ROUND10_PASS=K4256';
else put 'ERROR: ROUND10_FAIL=K4256 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4256:; quit;
