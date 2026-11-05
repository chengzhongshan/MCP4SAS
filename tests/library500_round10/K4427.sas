/* K4427 special_missing_relational_order, N=8; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:41 */

data k4427a; do j=1 to 8; x=.A; score=(x>. and x<0); output; end; run;
proc sql; create table k4427o as select sum(score) as actual from k4427a; quit;

data _null_; if 0 then set k4427o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4427 rows=' rows;
else do; set k4427o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND10_PASS=K4427';
else put 'ERROR: ROUND10_FAIL=K4427 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4427:; quit;
