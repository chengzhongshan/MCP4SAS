/* K4310 expression_missing_versus_zero, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data k4310a; do sample=1 to 11; expr1=.; expr2=0; output; end; run;
data k4310b; set k4310a; missing_count=cmiss(of expr:); run;
proc sql; create table k4310o as select sum(missing_count) as actual from k4310b; quit;

data _null_; if 0 then set k4310o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4310 rows=' rows;
else do; set k4310o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND10_PASS=K4310';
else put 'ERROR: ROUND10_FAIL=K4310 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4310:; quit;
