/* R533 sql_left_anti, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data r533a; do k=1 to 2*4; output; end; run;
data r533b; do k=2 to 2*4 by 2; output; end; run;
proc sql; create table r533o as select sum(a.k) as actual from r533a a left join r533b b on a.k=b.k where b.k is missing; quit;

data _null_; if 0 then set r533o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R533 rows=' rows;
else do; set r533o; if not missing(actual) and abs(actual-(16))<=1e-10*max(1,abs(16)) then put 'ROUND2_PASS=R533';
else put 'ERROR: ROUND2_FAIL=R533 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r533:; quit;
