/* R526 sql_inner_multiplicity, N=7; source: SAS-Useful-Codes/Macros/base4sas_developer/mp_assertscope.sas:124 */

data r526a; do k=1 to 7; output; output; end; run;
data r526b; do k=1 to 7; do j=1 to 3; output; end; end; run;
proc sql; create table r526o as select count(*) as actual from r526a a inner join r526b b on a.k=b.k; quit;

data _null_; if 0 then set r526o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R526 rows=' rows;
else do; set r526o; if not missing(actual) and abs(actual-(42))<=1e-10*max(1,abs(42)) then put 'ROUND2_PASS=R526';
else put 'ERROR: ROUND2_FAIL=R526 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r526:; quit;
