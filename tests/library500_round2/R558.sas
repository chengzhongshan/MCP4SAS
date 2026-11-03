/* R558 sql_union, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge Function IMPORTANT NOTES.sas:66 */

data r558a; do x=1 to 9; output; end; run;
data r558b; do x=9 to 2*9; output; end; run;
proc sql; create table r558c as select x from r558a union select x from r558b;
create table r558o as select sum(x) as actual from r558c; quit;

data _null_; if 0 then set r558o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R558 rows=' rows;
else do; set r558o; if not missing(actual) and abs(actual-(171))<=1e-10*max(1,abs(171)) then put 'ROUND2_PASS=R558';
else put 'ERROR: ROUND2_FAIL=R558 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r558:; quit;
