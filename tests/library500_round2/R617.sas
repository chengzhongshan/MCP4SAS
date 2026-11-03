/* R617 sql_not_exists, N=8; source: SAS-Useful-Codes/Macros/SAS_ondemand_scripts/proc_univariate_histogram.template.sas:35 */

data r617a; do k=1 to 2*8; output; end; run;
data r617b; do k=1 to 8; output; end; run;
proc sql; create table r617o as select sum(k) as actual from r617a a where not exists(select * from r617b b where b.k=a.k); quit;

data _null_; if 0 then set r617o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R617 rows=' rows;
else do; set r617o; if not missing(actual) and abs(actual-(100))<=1e-10*max(1,abs(100)) then put 'ROUND2_PASS=R617';
else put 'ERROR: ROUND2_FAIL=R617 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r617:; quit;
