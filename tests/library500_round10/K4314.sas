/* K4314 gene_identifier_symbol_component, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:4345 */

data k4314a; length gene $32; gene='ENSG01|MAP3K19'; expression=5; output; gene='ENSG02|R3HDM1'; expression=6; output; run;
data k4314b; set k4314a; symbol=scan(gene,2,'|'); if symbol in ('MAP3K19','R3HDM1'); run;
proc sql; create table k4314o as select sum(expression) as actual from k4314b; quit;

data _null_; if 0 then set k4314o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4314 rows=' rows;
else do; set k4314o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND10_PASS=K4314';
else put 'ERROR: ROUND10_FAIL=K4314 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4314:; quit;
