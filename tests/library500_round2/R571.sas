/* R571 sql_except, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Need to assign single vairible in Except procedure_Proc SQL to select unique rows from the first table.sas:882 */

data r571a; do x=1 to 2*2; output; end; run;
data r571b; do x=2 to 2*2 by 2; output; end; run;
proc sql; create table r571c as select x from r571a except select x from r571b;
create table r571o as select sum(x) as actual from r571c; quit;

data _null_; if 0 then set r571o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R571 rows=' rows;
else do; set r571o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND2_PASS=R571';
else put 'ERROR: ROUND2_FAIL=R571 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r571:; quit;
