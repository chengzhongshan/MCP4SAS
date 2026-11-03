/* R589 sql_intersect, N=10; source: SAS-Useful-Codes/Macros/SAS-macros-master/insect.sas:4 */

data r589a; do x=1 to 2*10; output; end; run;
data r589b; do x=10 to 3*10; output; end; run;
proc sql; create table r589c as select x from r589a intersect select x from r589b;
create table r589o as select sum(x) as actual from r589c; quit;

data _null_; if 0 then set r589o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R589 rows=' rows;
else do; set r589o; if not missing(actual) and abs(actual-(165))<=1e-10*max(1,abs(165)) then put 'ROUND2_PASS=R589';
else put 'ERROR: ROUND2_FAIL=R589 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r589:; quit;
