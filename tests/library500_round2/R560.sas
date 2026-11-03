/* R560 sql_union, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge Function IMPORTANT NOTES.sas:66 */

data r560a; do x=1 to 11; output; end; run;
data r560b; do x=11 to 2*11; output; end; run;
proc sql; create table r560c as select x from r560a union select x from r560b;
create table r560o as select sum(x) as actual from r560c; quit;

data _null_; if 0 then set r560o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R560 rows=' rows;
else do; set r560o; if not missing(actual) and abs(actual-(253))<=1e-10*max(1,abs(253)) then put 'ROUND2_PASS=R560';
else put 'ERROR: ROUND2_FAIL=R560 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r560:; quit;
