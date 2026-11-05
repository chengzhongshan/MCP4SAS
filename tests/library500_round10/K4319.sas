/* K4319 gene_identifier_symbol_component, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:4345 */

data k4319a; length gene $32; gene='ENSG01|MAP3K19'; expression=10; output; gene='ENSG02|R3HDM1'; expression=11; output; run;
data k4319b; set k4319a; symbol=scan(gene,2,'|'); if symbol in ('MAP3K19','R3HDM1'); run;
proc sql; create table k4319o as select sum(expression) as actual from k4319b; quit;

data _null_; if 0 then set k4319o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4319 rows=' rows;
else do; set k4319o; if not missing(actual) and abs(actual-(21))<=1e-9*max(1,abs(21)) then put 'ROUND10_PASS=K4319';
else put 'ERROR: ROUND10_FAIL=K4319 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4319:; quit;
