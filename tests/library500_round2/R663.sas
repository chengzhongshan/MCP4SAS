/* R663 sql_insert, N=4; source: SAS-Useful-Codes/Macros/Meta_macros/marandom.sas:488 */

data r663a; x=0; output; run;
data r663b; do x=1 to 4; output; end; run;
proc sql; insert into r663a select x from r663b;
create table r663o as select sum(x)+count(*) as actual from r663a; quit;

data _null_; if 0 then set r663o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R663 rows=' rows;
else do; set r663o; if not missing(actual) and abs(actual-(15))<=1e-10*max(1,abs(15)) then put 'ROUND2_PASS=R663';
else put 'ERROR: ROUND2_FAIL=R663 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r663:; quit;
