/* R658 sql_delete, N=9; source: SAS-Useful-Codes/Macros/MultiTranspose.sas:401 */

data r658a; do x=1 to 2*9; output; end; run;
proc sql; delete from r658a where x<=9;
create table r658o as select sum(x) as actual from r658a; quit;

data _null_; if 0 then set r658o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R658 rows=' rows;
else do; set r658o; if not missing(actual) and abs(actual-(126))<=1e-10*max(1,abs(126)) then put 'ROUND2_PASS=R658';
else put 'ERROR: ROUND2_FAIL=R658 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r658:; quit;
