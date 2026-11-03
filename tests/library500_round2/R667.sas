/* R667 sql_insert, N=8; source: SAS-Useful-Codes/Macros/Meta_macros/marandom.sas:488 */

data r667a; x=0; output; run;
data r667b; do x=1 to 8; output; end; run;
proc sql; insert into r667a select x from r667b;
create table r667o as select sum(x)+count(*) as actual from r667a; quit;

data _null_; if 0 then set r667o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R667 rows=' rows;
else do; set r667o; if not missing(actual) and abs(actual-(45))<=1e-10*max(1,abs(45)) then put 'ROUND2_PASS=R667';
else put 'ERROR: ROUND2_FAIL=R667 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r667:; quit;
