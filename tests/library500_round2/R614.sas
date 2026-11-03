/* R614 sql_not_exists, N=5; source: SAS-Useful-Codes/Macros/SAS_ondemand_scripts/proc_univariate_histogram.template.sas:35 */

data r614a; do k=1 to 2*5; output; end; run;
data r614b; do k=1 to 5; output; end; run;
proc sql; create table r614o as select sum(k) as actual from r614a a where not exists(select * from r614b b where b.k=a.k); quit;

data _null_; if 0 then set r614o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R614 rows=' rows;
else do; set r614o; if not missing(actual) and abs(actual-(40))<=1e-10*max(1,abs(40)) then put 'ROUND2_PASS=R614';
else put 'ERROR: ROUND2_FAIL=R614 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r614:; quit;
