/* R665 sql_insert, N=6; source: SAS-Useful-Codes/Macros/Meta_macros/marandom.sas:488 */

data r665a; x=0; output; run;
data r665b; do x=1 to 6; output; end; run;
proc sql; insert into r665a select x from r665b;
create table r665o as select sum(x)+count(*) as actual from r665a; quit;

data _null_; if 0 then set r665o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R665 rows=' rows;
else do; set r665o; if not missing(actual) and abs(actual-(28))<=1e-10*max(1,abs(28)) then put 'ROUND2_PASS=R665';
else put 'ERROR: ROUND2_FAIL=R665 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r665:; quit;
