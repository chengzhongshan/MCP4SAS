/* R524 sql_inner_multiplicity, N=5; source: SAS-Useful-Codes/Macros/base4sas_developer/mp_assertscope.sas:124 */

data r524a; do k=1 to 5; output; output; end; run;
data r524b; do k=1 to 5; do j=1 to 3; output; end; end; run;
proc sql; create table r524o as select count(*) as actual from r524a a inner join r524b b on a.k=b.k; quit;

data _null_; if 0 then set r524o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R524 rows=' rows;
else do; set r524o; if not missing(actual) and abs(actual-(30))<=1e-10*max(1,abs(30)) then put 'ROUND2_PASS=R524';
else put 'ERROR: ROUND2_FAIL=R524 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r524:; quit;
