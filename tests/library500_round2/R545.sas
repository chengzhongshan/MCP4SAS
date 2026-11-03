/* R545 sql_full_keys, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge two dataset with proc sql.sas:35 */

data r545a; do k=1 to 6; output; end; run;
data r545b; do k=6 to 2*6; output; end; run;
proc sql; create table r545o as select count(coalesce(a.k,b.k)) as actual from r545a a full join r545b b on a.k=b.k; quit;

data _null_; if 0 then set r545o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R545 rows=' rows;
else do; set r545o; if not missing(actual) and abs(actual-(12))<=1e-10*max(1,abs(12)) then put 'ROUND2_PASS=R545';
else put 'ERROR: ROUND2_FAIL=R545 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r545:; quit;
