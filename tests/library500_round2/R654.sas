/* R654 sql_delete, N=5; source: SAS-Useful-Codes/Macros/MultiTranspose.sas:401 */

data r654a; do x=1 to 2*5; output; end; run;
proc sql; delete from r654a where x<=5;
create table r654o as select sum(x) as actual from r654a; quit;

data _null_; if 0 then set r654o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R654 rows=' rows;
else do; set r654o; if not missing(actual) and abs(actual-(40))<=1e-10*max(1,abs(40)) then put 'ROUND2_PASS=R654';
else put 'ERROR: ROUND2_FAIL=R654 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r654:; quit;
