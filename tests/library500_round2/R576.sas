/* R576 sql_except, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Need to assign single vairible in Except procedure_Proc SQL to select unique rows from the first table.sas:882 */

data r576a; do x=1 to 2*7; output; end; run;
data r576b; do x=2 to 2*7 by 2; output; end; run;
proc sql; create table r576c as select x from r576a except select x from r576b;
create table r576o as select sum(x) as actual from r576c; quit;

data _null_; if 0 then set r576o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R576 rows=' rows;
else do; set r576o; if not missing(actual) and abs(actual-(49))<=1e-10*max(1,abs(49)) then put 'ROUND2_PASS=R576';
else put 'ERROR: ROUND2_FAIL=R576 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r576:; quit;
