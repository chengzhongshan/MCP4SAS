/* R534 sql_left_anti, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data r534a; do k=1 to 2*5; output; end; run;
data r534b; do k=2 to 2*5 by 2; output; end; run;
proc sql; create table r534o as select sum(a.k) as actual from r534a a left join r534b b on a.k=b.k where b.k is missing; quit;

data _null_; if 0 then set r534o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R534 rows=' rows;
else do; set r534o; if not missing(actual) and abs(actual-(25))<=1e-10*max(1,abs(25)) then put 'ROUND2_PASS=R534';
else put 'ERROR: ROUND2_FAIL=R534 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r534:; quit;
