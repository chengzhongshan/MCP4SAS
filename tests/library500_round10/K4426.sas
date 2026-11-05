/* K4426 special_missing_relational_order, N=7; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:41 */

data k4426a; do j=1 to 7; x=.A; score=(x>. and x<0); output; end; run;
proc sql; create table k4426o as select sum(score) as actual from k4426a; quit;

data _null_; if 0 then set k4426o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4426 rows=' rows;
else do; set k4426o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND10_PASS=K4426';
else put 'ERROR: ROUND10_FAIL=K4426 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4426:; quit;
