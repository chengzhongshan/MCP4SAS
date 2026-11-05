/* K4313 gene_identifier_symbol_component, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:4345 */

data k4313a; length gene $32; gene='ENSG01|MAP3K19'; expression=4; output; gene='ENSG02|R3HDM1'; expression=5; output; run;
data k4313b; set k4313a; symbol=scan(gene,2,'|'); if symbol in ('MAP3K19','R3HDM1'); run;
proc sql; create table k4313o as select sum(expression) as actual from k4313b; quit;

data _null_; if 0 then set k4313o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4313 rows=' rows;
else do; set k4313o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND10_PASS=K4313';
else put 'ERROR: ROUND10_FAIL=K4313 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4313:; quit;
