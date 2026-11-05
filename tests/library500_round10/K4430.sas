/* K4430 special_missing_relational_order, N=11; source: Applied Statistics and the SAS Programming Language, Fourth Edition.txt:41 */

data k4430a; do j=1 to 11; x=.A; score=(x>. and x<0); output; end; run;
proc sql; create table k4430o as select sum(score) as actual from k4430a; quit;

data _null_; if 0 then set k4430o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4430 rows=' rows;
else do; set k4430o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND10_PASS=K4430';
else put 'ERROR: ROUND10_FAIL=K4430 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4430:; quit;
