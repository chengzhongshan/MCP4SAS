/* R659 sql_delete, N=10; source: SAS-Useful-Codes/Macros/MultiTranspose.sas:401 */

data r659a; do x=1 to 2*10; output; end; run;
proc sql; delete from r659a where x<=10;
create table r659o as select sum(x) as actual from r659a; quit;

data _null_; if 0 then set r659o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R659 rows=' rows;
else do; set r659o; if not missing(actual) and abs(actual-(155))<=1e-10*max(1,abs(155)) then put 'ROUND2_PASS=R659';
else put 'ERROR: ROUND2_FAIL=R659 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r659:; quit;
