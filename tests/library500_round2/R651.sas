/* R651 sql_delete, N=2; source: SAS-Useful-Codes/Macros/MultiTranspose.sas:401 */

data r651a; do x=1 to 2*2; output; end; run;
proc sql; delete from r651a where x<=2;
create table r651o as select sum(x) as actual from r651a; quit;

data _null_; if 0 then set r651o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R651 rows=' rows;
else do; set r651o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND2_PASS=R651';
else put 'ERROR: ROUND2_FAIL=R651 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r651:; quit;
