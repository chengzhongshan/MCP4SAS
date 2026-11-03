/* R554 sql_union, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge Function IMPORTANT NOTES.sas:66 */

data r554a; do x=1 to 5; output; end; run;
data r554b; do x=5 to 2*5; output; end; run;
proc sql; create table r554c as select x from r554a union select x from r554b;
create table r554o as select sum(x) as actual from r554c; quit;

data _null_; if 0 then set r554o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R554 rows=' rows;
else do; set r554o; if not missing(actual) and abs(actual-(55))<=1e-10*max(1,abs(55)) then put 'ROUND2_PASS=R554';
else put 'ERROR: ROUND2_FAIL=R554 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r554:; quit;
