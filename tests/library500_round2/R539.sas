/* R539 sql_left_anti, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data r539a; do k=1 to 2*10; output; end; run;
data r539b; do k=2 to 2*10 by 2; output; end; run;
proc sql; create table r539o as select sum(a.k) as actual from r539a a left join r539b b on a.k=b.k where b.k is missing; quit;

data _null_; if 0 then set r539o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R539 rows=' rows;
else do; set r539o; if not missing(actual) and abs(actual-(100))<=1e-10*max(1,abs(100)) then put 'ROUND2_PASS=R539';
else put 'ERROR: ROUND2_FAIL=R539 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r539:; quit;
