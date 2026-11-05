/* K4425 special_missing_relational_order, N=6; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:41 */

data k4425a; do j=1 to 6; x=.A; score=(x>. and x<0); output; end; run;
proc sql; create table k4425o as select sum(score) as actual from k4425a; quit;

data _null_; if 0 then set k4425o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4425 rows=' rows;
else do; set k4425o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND10_PASS=K4425';
else put 'ERROR: ROUND10_FAIL=K4425 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4425:; quit;
