/* K4315 gene_identifier_symbol_component, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:4345 */

data k4315a; length gene $32; gene='ENSG01|MAP3K19'; expression=6; output; gene='ENSG02|R3HDM1'; expression=7; output; run;
data k4315b; set k4315a; symbol=scan(gene,2,'|'); if symbol in ('MAP3K19','R3HDM1'); run;
proc sql; create table k4315o as select sum(expression) as actual from k4315b; quit;

data _null_; if 0 then set k4315o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4315 rows=' rows;
else do; set k4315o; if not missing(actual) and abs(actual-(13))<=1e-9*max(1,abs(13)) then put 'ROUND10_PASS=K4315';
else put 'ERROR: ROUND10_FAIL=K4315 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4315:; quit;
