/* R579 sql_except, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Need to assign single vairible in Except procedure_Proc SQL to select unique rows from the first table.sas:882 */

data r579a; do x=1 to 2*10; output; end; run;
data r579b; do x=2 to 2*10 by 2; output; end; run;
proc sql; create table r579c as select x from r579a except select x from r579b;
create table r579o as select sum(x) as actual from r579c; quit;

data _null_; if 0 then set r579o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R579 rows=' rows;
else do; set r579o; if not missing(actual) and abs(actual-(100))<=1e-10*max(1,abs(100)) then put 'ROUND2_PASS=R579';
else put 'ERROR: ROUND2_FAIL=R579 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r579:; quit;
