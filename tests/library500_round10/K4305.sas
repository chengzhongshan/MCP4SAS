/* K4305 expression_missing_versus_zero, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data k4305a; do sample=1 to 6; expr1=.; expr2=0; output; end; run;
data k4305b; set k4305a; missing_count=cmiss(of expr:); run;
proc sql; create table k4305o as select sum(missing_count) as actual from k4305b; quit;

data _null_; if 0 then set k4305o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4305 rows=' rows;
else do; set k4305o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND10_PASS=K4305';
else put 'ERROR: ROUND10_FAIL=K4305 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4305:; quit;
