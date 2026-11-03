/* R669 sql_insert, N=10; source: SAS-Useful-Codes/Macros/Meta_macros/marandom.sas:488 */

data r669a; x=0; output; run;
data r669b; do x=1 to 10; output; end; run;
proc sql; insert into r669a select x from r669b;
create table r669o as select sum(x)+count(*) as actual from r669a; quit;

data _null_; if 0 then set r669o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R669 rows=' rows;
else do; set r669o; if not missing(actual) and abs(actual-(66))<=1e-10*max(1,abs(66)) then put 'ROUND2_PASS=R669';
else put 'ERROR: ROUND2_FAIL=R669 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r669:; quit;
