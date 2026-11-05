/* K4422 special_missing_relational_order, N=3; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:41 */

data k4422a; do j=1 to 3; x=.A; score=(x>. and x<0); output; end; run;
proc sql; create table k4422o as select sum(score) as actual from k4422a; quit;

data _null_; if 0 then set k4422o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4422 rows=' rows;
else do; set k4422o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND10_PASS=K4422';
else put 'ERROR: ROUND10_FAIL=K4422 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4422:; quit;
