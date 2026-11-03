/* R572 sql_except, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Need to assign single vairible in Except procedure_Proc SQL to select unique rows from the first table.sas:882 */

data r572a; do x=1 to 2*3; output; end; run;
data r572b; do x=2 to 2*3 by 2; output; end; run;
proc sql; create table r572c as select x from r572a except select x from r572b;
create table r572o as select sum(x) as actual from r572c; quit;

data _null_; if 0 then set r572o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R572 rows=' rows;
else do; set r572o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND2_PASS=R572';
else put 'ERROR: ROUND2_FAIL=R572 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r572:; quit;
