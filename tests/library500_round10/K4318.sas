/* K4318 gene_identifier_symbol_component, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:4345 */

data k4318a; length gene $32; gene='ENSG01|MAP3K19'; expression=9; output; gene='ENSG02|R3HDM1'; expression=10; output; run;
data k4318b; set k4318a; symbol=scan(gene,2,'|'); if symbol in ('MAP3K19','R3HDM1'); run;
proc sql; create table k4318o as select sum(expression) as actual from k4318b; quit;

data _null_; if 0 then set k4318o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4318 rows=' rows;
else do; set k4318o; if not missing(actual) and abs(actual-(19))<=1e-9*max(1,abs(19)) then put 'ROUND10_PASS=K4318';
else put 'ERROR: ROUND10_FAIL=K4318 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4318:; quit;
