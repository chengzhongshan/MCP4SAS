/* R573 sql_except, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Need to assign single vairible in Except procedure_Proc SQL to select unique rows from the first table.sas:882 */

data r573a; do x=1 to 2*4; output; end; run;
data r573b; do x=2 to 2*4 by 2; output; end; run;
proc sql; create table r573c as select x from r573a except select x from r573b;
create table r573o as select sum(x) as actual from r573c; quit;

data _null_; if 0 then set r573o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R573 rows=' rows;
else do; set r573o; if not missing(actual) and abs(actual-(16))<=1e-10*max(1,abs(16)) then put 'ROUND2_PASS=R573';
else put 'ERROR: ROUND2_FAIL=R573 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r573:; quit;
