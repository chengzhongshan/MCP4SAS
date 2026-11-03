/* R577 sql_except, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Need to assign single vairible in Except procedure_Proc SQL to select unique rows from the first table.sas:882 */

data r577a; do x=1 to 2*8; output; end; run;
data r577b; do x=2 to 2*8 by 2; output; end; run;
proc sql; create table r577c as select x from r577a except select x from r577b;
create table r577o as select sum(x) as actual from r577c; quit;

data _null_; if 0 then set r577o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R577 rows=' rows;
else do; set r577o; if not missing(actual) and abs(actual-(64))<=1e-10*max(1,abs(64)) then put 'ROUND2_PASS=R577';
else put 'ERROR: ROUND2_FAIL=R577 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r577:; quit;
