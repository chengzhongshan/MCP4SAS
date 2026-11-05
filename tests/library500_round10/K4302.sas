/* K4302 expression_missing_versus_zero, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data k4302a; do sample=1 to 3; expr1=.; expr2=0; output; end; run;
data k4302b; set k4302a; missing_count=cmiss(of expr:); run;
proc sql; create table k4302o as select sum(missing_count) as actual from k4302b; quit;

data _null_; if 0 then set k4302o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4302 rows=' rows;
else do; set k4302o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND10_PASS=K4302';
else put 'ERROR: ROUND10_FAIL=K4302 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4302:; quit;
