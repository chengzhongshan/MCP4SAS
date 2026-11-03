/* R664 sql_insert, N=5; source: SAS-Useful-Codes/Macros/Meta_macros/marandom.sas:488 */

data r664a; x=0; output; run;
data r664b; do x=1 to 5; output; end; run;
proc sql; insert into r664a select x from r664b;
create table r664o as select sum(x)+count(*) as actual from r664a; quit;

data _null_; if 0 then set r664o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R664 rows=' rows;
else do; set r664o; if not missing(actual) and abs(actual-(21))<=1e-10*max(1,abs(21)) then put 'ROUND2_PASS=R664';
else put 'ERROR: ROUND2_FAIL=R664 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r664:; quit;
