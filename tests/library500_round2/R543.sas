/* R543 sql_full_keys, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge two dataset with proc sql.sas:35 */

data r543a; do k=1 to 4; output; end; run;
data r543b; do k=4 to 2*4; output; end; run;
proc sql; create table r543o as select count(coalesce(a.k,b.k)) as actual from r543a a full join r543b b on a.k=b.k; quit;

data _null_; if 0 then set r543o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R543 rows=' rows;
else do; set r543o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND2_PASS=R543';
else put 'ERROR: ROUND2_FAIL=R543 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r543:; quit;
