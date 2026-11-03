/* R527 sql_inner_multiplicity, N=8; source: SAS-Useful-Codes/Macros/base4sas_developer/mp_assertscope.sas:124 */

data r527a; do k=1 to 8; output; output; end; run;
data r527b; do k=1 to 8; do j=1 to 3; output; end; end; run;
proc sql; create table r527o as select count(*) as actual from r527a a inner join r527b b on a.k=b.k; quit;

data _null_; if 0 then set r527o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R527 rows=' rows;
else do; set r527o; if not missing(actual) and abs(actual-(48))<=1e-10*max(1,abs(48)) then put 'ROUND2_PASS=R527';
else put 'ERROR: ROUND2_FAIL=R527 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r527:; quit;
