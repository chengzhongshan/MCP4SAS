/* R668 sql_insert, N=9; source: SAS-Useful-Codes/Macros/Meta_macros/marandom.sas:488 */

data r668a; x=0; output; run;
data r668b; do x=1 to 9; output; end; run;
proc sql; insert into r668a select x from r668b;
create table r668o as select sum(x)+count(*) as actual from r668a; quit;

data _null_; if 0 then set r668o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R668 rows=' rows;
else do; set r668o; if not missing(actual) and abs(actual-(55))<=1e-10*max(1,abs(55)) then put 'ROUND2_PASS=R668';
else put 'ERROR: ROUND2_FAIL=R668 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r668:; quit;
