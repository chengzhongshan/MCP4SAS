/* R528 sql_inner_multiplicity, N=9; source: SAS-Useful-Codes/Macros/base4sas_developer/mp_assertscope.sas:124 */

data r528a; do k=1 to 9; output; output; end; run;
data r528b; do k=1 to 9; do j=1 to 3; output; end; end; run;
proc sql; create table r528o as select count(*) as actual from r528a a inner join r528b b on a.k=b.k; quit;

data _null_; if 0 then set r528o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R528 rows=' rows;
else do; set r528o; if not missing(actual) and abs(actual-(54))<=1e-10*max(1,abs(54)) then put 'ROUND2_PASS=R528';
else put 'ERROR: ROUND2_FAIL=R528 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r528:; quit;
