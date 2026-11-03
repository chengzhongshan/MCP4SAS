/* R536 sql_left_anti, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data r536a; do k=1 to 2*7; output; end; run;
data r536b; do k=2 to 2*7 by 2; output; end; run;
proc sql; create table r536o as select sum(a.k) as actual from r536a a left join r536b b on a.k=b.k where b.k is missing; quit;

data _null_; if 0 then set r536o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R536 rows=' rows;
else do; set r536o; if not missing(actual) and abs(actual-(49))<=1e-10*max(1,abs(49)) then put 'ROUND2_PASS=R536';
else put 'ERROR: ROUND2_FAIL=R536 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r536:; quit;
