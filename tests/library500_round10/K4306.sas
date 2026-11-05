/* K4306 expression_missing_versus_zero, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data k4306a; do sample=1 to 7; expr1=.; expr2=0; output; end; run;
data k4306b; set k4306a; missing_count=cmiss(of expr:); run;
proc sql; create table k4306o as select sum(missing_count) as actual from k4306b; quit;

data _null_; if 0 then set k4306o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4306 rows=' rows;
else do; set k4306o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND10_PASS=K4306';
else put 'ERROR: ROUND10_FAIL=K4306 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4306:; quit;
