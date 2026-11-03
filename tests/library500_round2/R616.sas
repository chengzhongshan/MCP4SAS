/* R616 sql_not_exists, N=7; source: SAS-Useful-Codes/Macros/SAS_ondemand_scripts/proc_univariate_histogram.template.sas:35 */

data r616a; do k=1 to 2*7; output; end; run;
data r616b; do k=1 to 7; output; end; run;
proc sql; create table r616o as select sum(k) as actual from r616a a where not exists(select * from r616b b where b.k=a.k); quit;

data _null_; if 0 then set r616o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R616 rows=' rows;
else do; set r616o; if not missing(actual) and abs(actual-(77))<=1e-10*max(1,abs(77)) then put 'ROUND2_PASS=R616';
else put 'ERROR: ROUND2_FAIL=R616 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r616:; quit;
