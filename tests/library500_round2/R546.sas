/* R546 sql_full_keys, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge two dataset with proc sql.sas:35 */

data r546a; do k=1 to 7; output; end; run;
data r546b; do k=7 to 2*7; output; end; run;
proc sql; create table r546o as select count(coalesce(a.k,b.k)) as actual from r546a a full join r546b b on a.k=b.k; quit;

data _null_; if 0 then set r546o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R546 rows=' rows;
else do; set r546o; if not missing(actual) and abs(actual-(14))<=1e-10*max(1,abs(14)) then put 'ROUND2_PASS=R546';
else put 'ERROR: ROUND2_FAIL=R546 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r546:; quit;
