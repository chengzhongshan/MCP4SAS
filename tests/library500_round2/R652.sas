/* R652 sql_delete, N=3; source: SAS-Useful-Codes/Macros/MultiTranspose.sas:401 */

data r652a; do x=1 to 2*3; output; end; run;
proc sql; delete from r652a where x<=3;
create table r652o as select sum(x) as actual from r652a; quit;

data _null_; if 0 then set r652o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R652 rows=' rows;
else do; set r652o; if not missing(actual) and abs(actual-(15))<=1e-10*max(1,abs(15)) then put 'ROUND2_PASS=R652';
else put 'ERROR: ROUND2_FAIL=R652 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r652:; quit;
