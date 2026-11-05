/* K4251 matrix_filter_before_transpose, N=2; source: Combining and Modifying SAS Data Sets Examples, Version 6, First Edition.txt:400 */

data k4251a; length gene $12; array expr{*} v1-v2; do g=1 to 3; gene=cats('gene',g); do j=1 to dim(expr); expr{j}=g*j; end; output; end; drop j g; run;
data k4251b; set k4251a(where=(gene in ('gene1','gene2'))); array expr{*} v1-v2; do sample=1 to dim(expr); value=expr{sample}; output; end; keep gene sample value; run;
proc sql; create table k4251o as select count(*) as actual from k4251b; quit;

data _null_; if 0 then set k4251o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4251 rows=' rows;
else do; set k4251o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND10_PASS=K4251';
else put 'ERROR: ROUND10_FAIL=K4251 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4251:; quit;
