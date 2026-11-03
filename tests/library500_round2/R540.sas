/* R540 sql_left_anti, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data r540a; do k=1 to 2*11; output; end; run;
data r540b; do k=2 to 2*11 by 2; output; end; run;
proc sql; create table r540o as select sum(a.k) as actual from r540a a left join r540b b on a.k=b.k where b.k is missing; quit;

data _null_; if 0 then set r540o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R540 rows=' rows;
else do; set r540o; if not missing(actual) and abs(actual-(121))<=1e-10*max(1,abs(121)) then put 'ROUND2_PASS=R540';
else put 'ERROR: ROUND2_FAIL=R540 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r540:; quit;
