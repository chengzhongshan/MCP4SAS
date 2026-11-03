/* R620 sql_not_exists, N=11; source: SAS-Useful-Codes/Macros/SAS_ondemand_scripts/proc_univariate_histogram.template.sas:35 */

data r620a; do k=1 to 2*11; output; end; run;
data r620b; do k=1 to 11; output; end; run;
proc sql; create table r620o as select sum(k) as actual from r620a a where not exists(select * from r620b b where b.k=a.k); quit;

data _null_; if 0 then set r620o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R620 rows=' rows;
else do; set r620o; if not missing(actual) and abs(actual-(187))<=1e-10*max(1,abs(187)) then put 'ROUND2_PASS=R620';
else put 'ERROR: ROUND2_FAIL=R620 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r620:; quit;
