/* R525 sql_inner_multiplicity, N=6; source: SAS-Useful-Codes/Macros/base4sas_developer/mp_assertscope.sas:124 */

data r525a; do k=1 to 6; output; output; end; run;
data r525b; do k=1 to 6; do j=1 to 3; output; end; end; run;
proc sql; create table r525o as select count(*) as actual from r525a a inner join r525b b on a.k=b.k; quit;

data _null_; if 0 then set r525o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R525 rows=' rows;
else do; set r525o; if not missing(actual) and abs(actual-(36))<=1e-10*max(1,abs(36)) then put 'ROUND2_PASS=R525';
else put 'ERROR: ROUND2_FAIL=R525 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r525:; quit;
