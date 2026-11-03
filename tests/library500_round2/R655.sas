/* R655 sql_delete, N=6; source: SAS-Useful-Codes/Macros/MultiTranspose.sas:401 */

data r655a; do x=1 to 2*6; output; end; run;
proc sql; delete from r655a where x<=6;
create table r655o as select sum(x) as actual from r655a; quit;

data _null_; if 0 then set r655o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R655 rows=' rows;
else do; set r655o; if not missing(actual) and abs(actual-(57))<=1e-10*max(1,abs(57)) then put 'ROUND2_PASS=R655';
else put 'ERROR: ROUND2_FAIL=R655 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r655:; quit;
