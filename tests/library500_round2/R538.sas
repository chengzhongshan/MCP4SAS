/* R538 sql_left_anti, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data r538a; do k=1 to 2*9; output; end; run;
data r538b; do k=2 to 2*9 by 2; output; end; run;
proc sql; create table r538o as select sum(a.k) as actual from r538a a left join r538b b on a.k=b.k where b.k is missing; quit;

data _null_; if 0 then set r538o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R538 rows=' rows;
else do; set r538o; if not missing(actual) and abs(actual-(81))<=1e-10*max(1,abs(81)) then put 'ROUND2_PASS=R538';
else put 'ERROR: ROUND2_FAIL=R538 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r538:; quit;
