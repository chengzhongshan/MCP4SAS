/* R613 sql_not_exists, N=4; source: SAS-Useful-Codes/Macros/SAS_ondemand_scripts/proc_univariate_histogram.template.sas:35 */

data r613a; do k=1 to 2*4; output; end; run;
data r613b; do k=1 to 4; output; end; run;
proc sql; create table r613o as select sum(k) as actual from r613a a where not exists(select * from r613b b where b.k=a.k); quit;

data _null_; if 0 then set r613o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R613 rows=' rows;
else do; set r613o; if not missing(actual) and abs(actual-(26))<=1e-10*max(1,abs(26)) then put 'ROUND2_PASS=R613';
else put 'ERROR: ROUND2_FAIL=R613 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r613:; quit;
