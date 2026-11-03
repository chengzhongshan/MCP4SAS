/* R618 sql_not_exists, N=9; source: SAS-Useful-Codes/Macros/SAS_ondemand_scripts/proc_univariate_histogram.template.sas:35 */

data r618a; do k=1 to 2*9; output; end; run;
data r618b; do k=1 to 9; output; end; run;
proc sql; create table r618o as select sum(k) as actual from r618a a where not exists(select * from r618b b where b.k=a.k); quit;

data _null_; if 0 then set r618o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R618 rows=' rows;
else do; set r618o; if not missing(actual) and abs(actual-(126))<=1e-10*max(1,abs(126)) then put 'ROUND2_PASS=R618';
else put 'ERROR: ROUND2_FAIL=R618 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r618:; quit;
