/* R580 sql_except, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Need to assign single vairible in Except procedure_Proc SQL to select unique rows from the first table.sas:882 */

data r580a; do x=1 to 2*11; output; end; run;
data r580b; do x=2 to 2*11 by 2; output; end; run;
proc sql; create table r580c as select x from r580a except select x from r580b;
create table r580o as select sum(x) as actual from r580c; quit;

data _null_; if 0 then set r580o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R580 rows=' rows;
else do; set r580o; if not missing(actual) and abs(actual-(121))<=1e-10*max(1,abs(121)) then put 'ROUND2_PASS=R580';
else put 'ERROR: ROUND2_FAIL=R580 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r580:; quit;
