/* R549 sql_full_keys, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge two dataset with proc sql.sas:35 */

data r549a; do k=1 to 10; output; end; run;
data r549b; do k=10 to 2*10; output; end; run;
proc sql; create table r549o as select count(coalesce(a.k,b.k)) as actual from r549a a full join r549b b on a.k=b.k; quit;

data _null_; if 0 then set r549o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R549 rows=' rows;
else do; set r549o; if not missing(actual) and abs(actual-(20))<=1e-10*max(1,abs(20)) then put 'ROUND2_PASS=R549';
else put 'ERROR: ROUND2_FAIL=R549 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r549:; quit;
