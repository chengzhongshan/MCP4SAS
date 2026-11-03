/* R660 sql_delete, N=11; source: SAS-Useful-Codes/Macros/MultiTranspose.sas:401 */

data r660a; do x=1 to 2*11; output; end; run;
proc sql; delete from r660a where x<=11;
create table r660o as select sum(x) as actual from r660a; quit;

data _null_; if 0 then set r660o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R660 rows=' rows;
else do; set r660o; if not missing(actual) and abs(actual-(187))<=1e-10*max(1,abs(187)) then put 'ROUND2_PASS=R660';
else put 'ERROR: ROUND2_FAIL=R660 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r660:; quit;
