/* R530 sql_inner_multiplicity, N=11; source: SAS-Useful-Codes/Macros/base4sas_developer/mp_assertscope.sas:124 */

data r530a; do k=1 to 11; output; output; end; run;
data r530b; do k=1 to 11; do j=1 to 3; output; end; end; run;
proc sql; create table r530o as select count(*) as actual from r530a a inner join r530b b on a.k=b.k; quit;

data _null_; if 0 then set r530o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R530 rows=' rows;
else do; set r530o; if not missing(actual) and abs(actual-(66))<=1e-10*max(1,abs(66)) then put 'ROUND2_PASS=R530';
else put 'ERROR: ROUND2_FAIL=R530 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r530:; quit;
