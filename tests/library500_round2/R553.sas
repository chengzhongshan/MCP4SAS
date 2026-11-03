/* R553 sql_union, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge Function IMPORTANT NOTES.sas:66 */

data r553a; do x=1 to 4; output; end; run;
data r553b; do x=4 to 2*4; output; end; run;
proc sql; create table r553c as select x from r553a union select x from r553b;
create table r553o as select sum(x) as actual from r553c; quit;

data _null_; if 0 then set r553o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R553 rows=' rows;
else do; set r553o; if not missing(actual) and abs(actual-(36))<=1e-10*max(1,abs(36)) then put 'ROUND2_PASS=R553';
else put 'ERROR: ROUND2_FAIL=R553 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r553:; quit;
