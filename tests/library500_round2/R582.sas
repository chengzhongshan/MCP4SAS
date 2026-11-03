/* R582 sql_intersect, N=3; source: SAS-Useful-Codes/Macros/SAS-macros-master/insect.sas:4 */

data r582a; do x=1 to 2*3; output; end; run;
data r582b; do x=3 to 3*3; output; end; run;
proc sql; create table r582c as select x from r582a intersect select x from r582b;
create table r582o as select sum(x) as actual from r582c; quit;

data _null_; if 0 then set r582o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R582 rows=' rows;
else do; set r582o; if not missing(actual) and abs(actual-(18))<=1e-10*max(1,abs(18)) then put 'ROUND2_PASS=R582';
else put 'ERROR: ROUND2_FAIL=R582 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r582:; quit;
