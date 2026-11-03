/* R656 sql_delete, N=7; source: SAS-Useful-Codes/Macros/MultiTranspose.sas:401 */

data r656a; do x=1 to 2*7; output; end; run;
proc sql; delete from r656a where x<=7;
create table r656o as select sum(x) as actual from r656a; quit;

data _null_; if 0 then set r656o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R656 rows=' rows;
else do; set r656o; if not missing(actual) and abs(actual-(77))<=1e-10*max(1,abs(77)) then put 'ROUND2_PASS=R656';
else put 'ERROR: ROUND2_FAIL=R656 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r656:; quit;
