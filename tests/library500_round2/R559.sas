/* R559 sql_union, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Merge Function IMPORTANT NOTES.sas:66 */

data r559a; do x=1 to 10; output; end; run;
data r559b; do x=10 to 2*10; output; end; run;
proc sql; create table r559c as select x from r559a union select x from r559b;
create table r559o as select sum(x) as actual from r559c; quit;

data _null_; if 0 then set r559o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R559 rows=' rows;
else do; set r559o; if not missing(actual) and abs(actual-(210))<=1e-10*max(1,abs(210)) then put 'ROUND2_PASS=R559';
else put 'ERROR: ROUND2_FAIL=R559 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r559:; quit;
