/* K4320 gene_identifier_symbol_component, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:4345 */

data k4320a; length gene $32; gene='ENSG01|MAP3K19'; expression=11; output; gene='ENSG02|R3HDM1'; expression=12; output; run;
data k4320b; set k4320a; symbol=scan(gene,2,'|'); if symbol in ('MAP3K19','R3HDM1'); run;
proc sql; create table k4320o as select sum(expression) as actual from k4320b; quit;

data _null_; if 0 then set k4320o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4320 rows=' rows;
else do; set k4320o; if not missing(actual) and abs(actual-(23))<=1e-9*max(1,abs(23)) then put 'ROUND10_PASS=K4320';
else put 'ERROR: ROUND10_FAIL=K4320 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4320:; quit;
