/* K4301 expression_missing_versus_zero, N=2; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data k4301a; do sample=1 to 2; expr1=.; expr2=0; output; end; run;
data k4301b; set k4301a; missing_count=cmiss(of expr:); run;
proc sql; create table k4301o as select sum(missing_count) as actual from k4301b; quit;

data _null_; if 0 then set k4301o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4301 rows=' rows;
else do; set k4301o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND10_PASS=K4301';
else put 'ERROR: ROUND10_FAIL=K4301 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4301:; quit;
