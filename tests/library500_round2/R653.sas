/* R653 sql_delete, N=4; source: SAS-Useful-Codes/Macros/MultiTranspose.sas:401 */

data r653a; do x=1 to 2*4; output; end; run;
proc sql; delete from r653a where x<=4;
create table r653o as select sum(x) as actual from r653a; quit;

data _null_; if 0 then set r653o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R653 rows=' rows;
else do; set r653o; if not missing(actual) and abs(actual-(26))<=1e-10*max(1,abs(26)) then put 'ROUND2_PASS=R653';
else put 'ERROR: ROUND2_FAIL=R653 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r653:; quit;
