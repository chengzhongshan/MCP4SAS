/* K4309 expression_missing_versus_zero, N=10; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:776 */

data k4309a; do sample=1 to 10; expr1=.; expr2=0; output; end; run;
data k4309b; set k4309a; missing_count=cmiss(of expr:); run;
proc sql; create table k4309o as select sum(missing_count) as actual from k4309b; quit;

data _null_; if 0 then set k4309o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4309 rows=' rows;
else do; set k4309o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND10_PASS=K4309';
else put 'ERROR: ROUND10_FAIL=K4309 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4309:; quit;
