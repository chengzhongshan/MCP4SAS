/* R661 sql_insert, N=2; source: SAS-Useful-Codes/Macros/Meta_macros/marandom.sas:488 */

data r661a; x=0; output; run;
data r661b; do x=1 to 2; output; end; run;
proc sql; insert into r661a select x from r661b;
create table r661o as select sum(x)+count(*) as actual from r661a; quit;

data _null_; if 0 then set r661o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R661 rows=' rows;
else do; set r661o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND2_PASS=R661';
else put 'ERROR: ROUND2_FAIL=R661 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r661:; quit;
