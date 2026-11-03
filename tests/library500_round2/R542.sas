/* R542 sql_full_keys, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge two dataset with proc sql.sas:35 */

data r542a; do k=1 to 3; output; end; run;
data r542b; do k=3 to 2*3; output; end; run;
proc sql; create table r542o as select count(coalesce(a.k,b.k)) as actual from r542a a full join r542b b on a.k=b.k; quit;

data _null_; if 0 then set r542o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R542 rows=' rows;
else do; set r542o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND2_PASS=R542';
else put 'ERROR: ROUND2_FAIL=R542 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r542:; quit;
