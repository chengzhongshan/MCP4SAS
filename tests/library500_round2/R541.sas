/* R541 sql_full_keys, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge two dataset with proc sql.sas:35 */

data r541a; do k=1 to 2; output; end; run;
data r541b; do k=2 to 2*2; output; end; run;
proc sql; create table r541o as select count(coalesce(a.k,b.k)) as actual from r541a a full join r541b b on a.k=b.k; quit;

data _null_; if 0 then set r541o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R541 rows=' rows;
else do; set r541o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND2_PASS=R541';
else put 'ERROR: ROUND2_FAIL=R541 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r541:; quit;
