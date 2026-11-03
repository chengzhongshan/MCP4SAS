/* R612 sql_not_exists, N=3; source: SAS-Useful-Codes/Macros/SAS_ondemand_scripts/proc_univariate_histogram.template.sas:35 */

data r612a; do k=1 to 2*3; output; end; run;
data r612b; do k=1 to 3; output; end; run;
proc sql; create table r612o as select sum(k) as actual from r612a a where not exists(select * from r612b b where b.k=a.k); quit;

data _null_; if 0 then set r612o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R612 rows=' rows;
else do; set r612o; if not missing(actual) and abs(actual-(15))<=1e-10*max(1,abs(15)) then put 'ROUND2_PASS=R612';
else put 'ERROR: ROUND2_FAIL=R612 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r612:; quit;
