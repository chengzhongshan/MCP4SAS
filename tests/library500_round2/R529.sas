/* R529 sql_inner_multiplicity, N=10; source: SAS-Useful-Codes/Macros/base4sas_developer/mp_assertscope.sas:124 */

data r529a; do k=1 to 10; output; output; end; run;
data r529b; do k=1 to 10; do j=1 to 3; output; end; end; run;
proc sql; create table r529o as select count(*) as actual from r529a a inner join r529b b on a.k=b.k; quit;

data _null_; if 0 then set r529o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R529 rows=' rows;
else do; set r529o; if not missing(actual) and abs(actual-(60))<=1e-10*max(1,abs(60)) then put 'ROUND2_PASS=R529';
else put 'ERROR: ROUND2_FAIL=R529 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r529:; quit;
