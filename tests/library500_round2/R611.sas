/* R611 sql_not_exists, N=2; source: SAS-Useful-Codes/Macros/SAS_ondemand_scripts/proc_univariate_histogram.template.sas:35 */

data r611a; do k=1 to 2*2; output; end; run;
data r611b; do k=1 to 2; output; end; run;
proc sql; create table r611o as select sum(k) as actual from r611a a where not exists(select * from r611b b where b.k=a.k); quit;

data _null_; if 0 then set r611o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R611 rows=' rows;
else do; set r611o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND2_PASS=R611';
else put 'ERROR: ROUND2_FAIL=R611 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r611:; quit;
