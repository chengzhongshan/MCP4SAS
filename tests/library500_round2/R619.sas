/* R619 sql_not_exists, N=10; source: SAS-Useful-Codes/Macros/SAS_ondemand_scripts/proc_univariate_histogram.template.sas:35 */

data r619a; do k=1 to 2*10; output; end; run;
data r619b; do k=1 to 10; output; end; run;
proc sql; create table r619o as select sum(k) as actual from r619a a where not exists(select * from r619b b where b.k=a.k); quit;

data _null_; if 0 then set r619o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R619 rows=' rows;
else do; set r619o; if not missing(actual) and abs(actual-(155))<=1e-10*max(1,abs(155)) then put 'ROUND2_PASS=R619';
else put 'ERROR: ROUND2_FAIL=R619 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r619:; quit;
