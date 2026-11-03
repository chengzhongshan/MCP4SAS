/* R585 sql_intersect, N=6; source: SAS-Useful-Codes/Macros/SAS-macros-master/insect.sas:4 */

data r585a; do x=1 to 2*6; output; end; run;
data r585b; do x=6 to 3*6; output; end; run;
proc sql; create table r585c as select x from r585a intersect select x from r585b;
create table r585o as select sum(x) as actual from r585c; quit;

data _null_; if 0 then set r585o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R585 rows=' rows;
else do; set r585o; if not missing(actual) and abs(actual-(63))<=1e-10*max(1,abs(63)) then put 'ROUND2_PASS=R585';
else put 'ERROR: ROUND2_FAIL=R585 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r585:; quit;
