/* K4311 gene_identifier_symbol_component, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:4345 */

data k4311a; length gene $32; gene='ENSG01|MAP3K19'; expression=2; output; gene='ENSG02|R3HDM1'; expression=3; output; run;
data k4311b; set k4311a; symbol=scan(gene,2,'|'); if symbol in ('MAP3K19','R3HDM1'); run;
proc sql; create table k4311o as select sum(expression) as actual from k4311b; quit;

data _null_; if 0 then set k4311o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4311 rows=' rows;
else do; set k4311o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND10_PASS=K4311';
else put 'ERROR: ROUND10_FAIL=K4311 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4311:; quit;
