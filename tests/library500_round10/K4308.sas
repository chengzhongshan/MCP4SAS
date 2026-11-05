/* K4308 expression_missing_versus_zero, N=9; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data k4308a; do sample=1 to 9; expr1=.; expr2=0; output; end; run;
data k4308b; set k4308a; missing_count=cmiss(of expr:); run;
proc sql; create table k4308o as select sum(missing_count) as actual from k4308b; quit;

data _null_; if 0 then set k4308o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4308 rows=' rows;
else do; set k4308o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND10_PASS=K4308';
else put 'ERROR: ROUND10_FAIL=K4308 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4308:; quit;
