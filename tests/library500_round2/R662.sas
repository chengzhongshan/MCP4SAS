/* R662 sql_insert, N=3; source: SAS-Useful-Codes/Macros/Meta_macros/marandom.sas:488 */

data r662a; x=0; output; run;
data r662b; do x=1 to 3; output; end; run;
proc sql; insert into r662a select x from r662b;
create table r662o as select sum(x)+count(*) as actual from r662a; quit;

data _null_; if 0 then set r662o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R662 rows=' rows;
else do; set r662o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND2_PASS=R662';
else put 'ERROR: ROUND2_FAIL=R662 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r662:; quit;
