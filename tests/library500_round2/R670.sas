/* R670 sql_insert, N=11; source: SAS-Useful-Codes/Macros/Meta_macros/marandom.sas:488 */

data r670a; x=0; output; run;
data r670b; do x=1 to 11; output; end; run;
proc sql; insert into r670a select x from r670b;
create table r670o as select sum(x)+count(*) as actual from r670a; quit;

data _null_; if 0 then set r670o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R670 rows=' rows;
else do; set r670o; if not missing(actual) and abs(actual-(78))<=1e-10*max(1,abs(78)) then put 'ROUND2_PASS=R670';
else put 'ERROR: ROUND2_FAIL=R670 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r670:; quit;
