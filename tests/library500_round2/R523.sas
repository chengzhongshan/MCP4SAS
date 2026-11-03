/* R523 sql_inner_multiplicity, N=4; source: SAS-Useful-Codes/Macros/base4sas_developer/mp_assertscope.sas:124 */

data r523a; do k=1 to 4; output; output; end; run;
data r523b; do k=1 to 4; do j=1 to 3; output; end; end; run;
proc sql; create table r523o as select count(*) as actual from r523a a inner join r523b b on a.k=b.k; quit;

data _null_; if 0 then set r523o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R523 rows=' rows;
else do; set r523o; if not missing(actual) and abs(actual-(24))<=1e-10*max(1,abs(24)) then put 'ROUND2_PASS=R523';
else put 'ERROR: ROUND2_FAIL=R523 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r523:; quit;
