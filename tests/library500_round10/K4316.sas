/* K4316 gene_identifier_symbol_component, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:4345 */

data k4316a; length gene $32; gene='ENSG01|MAP3K19'; expression=7; output; gene='ENSG02|R3HDM1'; expression=8; output; run;
data k4316b; set k4316a; symbol=scan(gene,2,'|'); if symbol in ('MAP3K19','R3HDM1'); run;
proc sql; create table k4316o as select sum(expression) as actual from k4316b; quit;

data _null_; if 0 then set k4316o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4316 rows=' rows;
else do; set k4316o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND10_PASS=K4316';
else put 'ERROR: ROUND10_FAIL=K4316 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4316:; quit;
