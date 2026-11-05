/* K4253 matrix_filter_before_transpose, N=4; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:400 */

data k4253a; length gene $12; array expr{*} v1-v4; do g=1 to 3; gene=cats('gene',g); do j=1 to dim(expr); expr{j}=g*j; end; output; end; drop j g; run;
data k4253b; set k4253a(where=(gene in ('gene1','gene2'))); array expr{*} v1-v4; do sample=1 to dim(expr); value=expr{sample}; output; end; keep gene sample value; run;
proc sql; create table k4253o as select count(*) as actual from k4253b; quit;

data _null_; if 0 then set k4253o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4253 rows=' rows;
else do; set k4253o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND10_PASS=K4253';
else put 'ERROR: ROUND10_FAIL=K4253 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4253:; quit;
