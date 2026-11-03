/* R555 sql_union, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge Function IMPORTANT NOTES.sas:66 */

data r555a; do x=1 to 6; output; end; run;
data r555b; do x=6 to 2*6; output; end; run;
proc sql; create table r555c as select x from r555a union select x from r555b;
create table r555o as select sum(x) as actual from r555c; quit;

data _null_; if 0 then set r555o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R555 rows=' rows;
else do; set r555o; if not missing(actual) and abs(actual-(78))<=1e-10*max(1,abs(78)) then put 'ROUND2_PASS=R555';
else put 'ERROR: ROUND2_FAIL=R555 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r555:; quit;
