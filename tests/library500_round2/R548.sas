/* R548 sql_full_keys, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge two dataset with proc sql.sas:35 */

data r548a; do k=1 to 9; output; end; run;
data r548b; do k=9 to 2*9; output; end; run;
proc sql; create table r548o as select count(coalesce(a.k,b.k)) as actual from r548a a full join r548b b on a.k=b.k; quit;

data _null_; if 0 then set r548o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R548 rows=' rows;
else do; set r548o; if not missing(actual) and abs(actual-(18))<=1e-10*max(1,abs(18)) then put 'ROUND2_PASS=R548';
else put 'ERROR: ROUND2_FAIL=R548 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r548:; quit;
