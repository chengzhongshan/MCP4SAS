/* R550 sql_full_keys, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge two dataset with proc sql.sas:35 */

data r550a; do k=1 to 11; output; end; run;
data r550b; do k=11 to 2*11; output; end; run;
proc sql; create table r550o as select count(coalesce(a.k,b.k)) as actual from r550a a full join r550b b on a.k=b.k; quit;

data _null_; if 0 then set r550o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R550 rows=' rows;
else do; set r550o; if not missing(actual) and abs(actual-(22))<=1e-10*max(1,abs(22)) then put 'ROUND2_PASS=R550';
else put 'ERROR: ROUND2_FAIL=R550 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r550:; quit;
