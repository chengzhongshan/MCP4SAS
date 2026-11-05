/* K4307 expression_missing_versus_zero, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data k4307a; do sample=1 to 8; expr1=.; expr2=0; output; end; run;
data k4307b; set k4307a; missing_count=cmiss(of expr:); run;
proc sql; create table k4307o as select sum(missing_count) as actual from k4307b; quit;

data _null_; if 0 then set k4307o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4307 rows=' rows;
else do; set k4307o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND10_PASS=K4307';
else put 'ERROR: ROUND10_FAIL=K4307 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4307:; quit;
