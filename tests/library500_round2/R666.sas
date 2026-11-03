/* R666 sql_insert, N=7; source: SAS-Useful-Codes/Macros/Meta_macros/marandom.sas:488 */

data r666a; x=0; output; run;
data r666b; do x=1 to 7; output; end; run;
proc sql; insert into r666a select x from r666b;
create table r666o as select sum(x)+count(*) as actual from r666a; quit;

data _null_; if 0 then set r666o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R666 rows=' rows;
else do; set r666o; if not missing(actual) and abs(actual-(36))<=1e-10*max(1,abs(36)) then put 'ROUND2_PASS=R666';
else put 'ERROR: ROUND2_FAIL=R666 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r666:; quit;
