/* R537 sql_left_anti, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data r537a; do k=1 to 2*8; output; end; run;
data r537b; do k=2 to 2*8 by 2; output; end; run;
proc sql; create table r537o as select sum(a.k) as actual from r537a a left join r537b b on a.k=b.k where b.k is missing; quit;

data _null_; if 0 then set r537o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R537 rows=' rows;
else do; set r537o; if not missing(actual) and abs(actual-(64))<=1e-10*max(1,abs(64)) then put 'ROUND2_PASS=R537';
else put 'ERROR: ROUND2_FAIL=R537 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r537:; quit;
