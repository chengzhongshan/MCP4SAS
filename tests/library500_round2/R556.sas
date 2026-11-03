/* R556 sql_union, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge Function IMPORTANT NOTES.sas:66 */

data r556a; do x=1 to 7; output; end; run;
data r556b; do x=7 to 2*7; output; end; run;
proc sql; create table r556c as select x from r556a union select x from r556b;
create table r556o as select sum(x) as actual from r556c; quit;

data _null_; if 0 then set r556o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R556 rows=' rows;
else do; set r556o; if not missing(actual) and abs(actual-(105))<=1e-10*max(1,abs(105)) then put 'ROUND2_PASS=R556';
else put 'ERROR: ROUND2_FAIL=R556 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r556:; quit;
