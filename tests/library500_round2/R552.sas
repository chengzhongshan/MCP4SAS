/* R552 sql_union, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge Function IMPORTANT NOTES.sas:66 */

data r552a; do x=1 to 3; output; end; run;
data r552b; do x=3 to 2*3; output; end; run;
proc sql; create table r552c as select x from r552a union select x from r552b;
create table r552o as select sum(x) as actual from r552c; quit;

data _null_; if 0 then set r552o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R552 rows=' rows;
else do; set r552o; if not missing(actual) and abs(actual-(21))<=1e-10*max(1,abs(21)) then put 'ROUND2_PASS=R552';
else put 'ERROR: ROUND2_FAIL=R552 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r552:; quit;
