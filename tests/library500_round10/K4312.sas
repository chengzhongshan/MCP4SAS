/* K4312 gene_identifier_symbol_component, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:4345 */

data k4312a; length gene $32; gene='ENSG01|MAP3K19'; expression=3; output; gene='ENSG02|R3HDM1'; expression=4; output; run;
data k4312b; set k4312a; symbol=scan(gene,2,'|'); if symbol in ('MAP3K19','R3HDM1'); run;
proc sql; create table k4312o as select sum(expression) as actual from k4312b; quit;

data _null_; if 0 then set k4312o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4312 rows=' rows;
else do; set k4312o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND10_PASS=K4312';
else put 'ERROR: ROUND10_FAIL=K4312 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4312:; quit;
