/* R551 sql_union, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge Function IMPORTANT NOTES.sas:66 */

data r551a; do x=1 to 2; output; end; run;
data r551b; do x=2 to 2*2; output; end; run;
proc sql; create table r551c as select x from r551a union select x from r551b;
create table r551o as select sum(x) as actual from r551c; quit;

data _null_; if 0 then set r551o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R551 rows=' rows;
else do; set r551o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND2_PASS=R551';
else put 'ERROR: ROUND2_FAIL=R551 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r551:; quit;
