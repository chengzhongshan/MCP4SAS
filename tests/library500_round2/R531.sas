/* R531 sql_left_anti, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data r531a; do k=1 to 2*2; output; end; run;
data r531b; do k=2 to 2*2 by 2; output; end; run;
proc sql; create table r531o as select sum(a.k) as actual from r531a a left join r531b b on a.k=b.k where b.k is missing; quit;

data _null_; if 0 then set r531o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R531 rows=' rows;
else do; set r531o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND2_PASS=R531';
else put 'ERROR: ROUND2_FAIL=R531 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r531:; quit;
