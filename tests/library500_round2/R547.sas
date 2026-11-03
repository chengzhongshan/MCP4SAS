/* R547 sql_full_keys, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge two dataset with proc sql.sas:35 */

data r547a; do k=1 to 8; output; end; run;
data r547b; do k=8 to 2*8; output; end; run;
proc sql; create table r547o as select count(coalesce(a.k,b.k)) as actual from r547a a full join r547b b on a.k=b.k; quit;

data _null_; if 0 then set r547o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R547 rows=' rows;
else do; set r547o; if not missing(actual) and abs(actual-(16))<=1e-10*max(1,abs(16)) then put 'ROUND2_PASS=R547';
else put 'ERROR: ROUND2_FAIL=R547 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r547:; quit;
