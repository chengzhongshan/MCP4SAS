/* R544 sql_full_keys, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge two dataset with proc sql.sas:35 */

data r544a; do k=1 to 5; output; end; run;
data r544b; do k=5 to 2*5; output; end; run;
proc sql; create table r544o as select count(coalesce(a.k,b.k)) as actual from r544a a full join r544b b on a.k=b.k; quit;

data _null_; if 0 then set r544o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R544 rows=' rows;
else do; set r544o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND2_PASS=R544';
else put 'ERROR: ROUND2_FAIL=R544 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r544:; quit;
