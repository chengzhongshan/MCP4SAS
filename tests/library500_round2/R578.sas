/* R578 sql_except, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Need to assign single vairible in Except procedure_Proc SQL to select unique rows from the first table.sas:882 */

data r578a; do x=1 to 2*9; output; end; run;
data r578b; do x=2 to 2*9 by 2; output; end; run;
proc sql; create table r578c as select x from r578a except select x from r578b;
create table r578o as select sum(x) as actual from r578c; quit;

data _null_; if 0 then set r578o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R578 rows=' rows;
else do; set r578o; if not missing(actual) and abs(actual-(81))<=1e-10*max(1,abs(81)) then put 'ROUND2_PASS=R578';
else put 'ERROR: ROUND2_FAIL=R578 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r578:; quit;
