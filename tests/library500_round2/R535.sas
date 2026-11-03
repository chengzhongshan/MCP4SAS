/* R535 sql_left_anti, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data r535a; do k=1 to 2*6; output; end; run;
data r535b; do k=2 to 2*6 by 2; output; end; run;
proc sql; create table r535o as select sum(a.k) as actual from r535a a left join r535b b on a.k=b.k where b.k is missing; quit;

data _null_; if 0 then set r535o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R535 rows=' rows;
else do; set r535o; if not missing(actual) and abs(actual-(36))<=1e-10*max(1,abs(36)) then put 'ROUND2_PASS=R535';
else put 'ERROR: ROUND2_FAIL=R535 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r535:; quit;
