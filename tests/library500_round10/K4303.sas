/* K4303 expression_missing_versus_zero, N=4; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data k4303a; do sample=1 to 4; expr1=.; expr2=0; output; end; run;
data k4303b; set k4303a; missing_count=cmiss(of expr:); run;
proc sql; create table k4303o as select sum(missing_count) as actual from k4303b; quit;

data _null_; if 0 then set k4303o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4303 rows=' rows;
else do; set k4303o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND10_PASS=K4303';
else put 'ERROR: ROUND10_FAIL=K4303 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4303:; quit;
