/* R575 sql_except, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Need to assign single vairible in Except procedure_Proc SQL to select unique rows from the first table.sas:882 */

data r575a; do x=1 to 2*6; output; end; run;
data r575b; do x=2 to 2*6 by 2; output; end; run;
proc sql; create table r575c as select x from r575a except select x from r575b;
create table r575o as select sum(x) as actual from r575c; quit;

data _null_; if 0 then set r575o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R575 rows=' rows;
else do; set r575o; if not missing(actual) and abs(actual-(36))<=1e-10*max(1,abs(36)) then put 'ROUND2_PASS=R575';
else put 'ERROR: ROUND2_FAIL=R575 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r575:; quit;
