/* K4304 expression_missing_versus_zero, N=5; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data k4304a; do sample=1 to 5; expr1=.; expr2=0; output; end; run;
data k4304b; set k4304a; missing_count=cmiss(of expr:); run;
proc sql; create table k4304o as select sum(missing_count) as actual from k4304b; quit;

data _null_; if 0 then set k4304o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4304 rows=' rows;
else do; set k4304o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND10_PASS=K4304';
else put 'ERROR: ROUND10_FAIL=K4304 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4304:; quit;
