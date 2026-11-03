/* R615 sql_not_exists, N=6; source: SAS-Useful-Codes/Macros/SAS_ondemand_scripts/proc_univariate_histogram.template.sas:35 */

data r615a; do k=1 to 2*6; output; end; run;
data r615b; do k=1 to 6; output; end; run;
proc sql; create table r615o as select sum(k) as actual from r615a a where not exists(select * from r615b b where b.k=a.k); quit;

data _null_; if 0 then set r615o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R615 rows=' rows;
else do; set r615o; if not missing(actual) and abs(actual-(57))<=1e-10*max(1,abs(57)) then put 'ROUND2_PASS=R615';
else put 'ERROR: ROUND2_FAIL=R615 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r615:; quit;
