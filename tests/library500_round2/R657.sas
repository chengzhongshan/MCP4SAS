/* R657 sql_delete, N=8; source: SAS-Useful-Codes/Macros/MultiTranspose.sas:401 */

data r657a; do x=1 to 2*8; output; end; run;
proc sql; delete from r657a where x<=8;
create table r657o as select sum(x) as actual from r657a; quit;

data _null_; if 0 then set r657o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R657 rows=' rows;
else do; set r657o; if not missing(actual) and abs(actual-(100))<=1e-10*max(1,abs(100)) then put 'ROUND2_PASS=R657';
else put 'ERROR: ROUND2_FAIL=R657 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r657:; quit;
