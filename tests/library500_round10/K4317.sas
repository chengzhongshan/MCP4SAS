/* K4317 gene_identifier_symbol_component, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:4345 */

data k4317a; length gene $32; gene='ENSG01|MAP3K19'; expression=8; output; gene='ENSG02|R3HDM1'; expression=9; output; run;
data k4317b; set k4317a; symbol=scan(gene,2,'|'); if symbol in ('MAP3K19','R3HDM1'); run;
proc sql; create table k4317o as select sum(expression) as actual from k4317b; quit;

data _null_; if 0 then set k4317o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4317 rows=' rows;
else do; set k4317o; if not missing(actual) and abs(actual-(17))<=1e-9*max(1,abs(17)) then put 'ROUND10_PASS=K4317';
else put 'ERROR: ROUND10_FAIL=K4317 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4317:; quit;
