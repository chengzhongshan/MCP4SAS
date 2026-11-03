/* R590 sql_intersect, N=11; source: SAS-Useful-Codes/Macros/SAS-macros-master/insect.sas:4 */

data r590a; do x=1 to 2*11; output; end; run;
data r590b; do x=11 to 3*11; output; end; run;
proc sql; create table r590c as select x from r590a intersect select x from r590b;
create table r590o as select sum(x) as actual from r590c; quit;

data _null_; if 0 then set r590o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R590 rows=' rows;
else do; set r590o; if not missing(actual) and abs(actual-(198))<=1e-10*max(1,abs(198)) then put 'ROUND2_PASS=R590';
else put 'ERROR: ROUND2_FAIL=R590 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r590:; quit;
