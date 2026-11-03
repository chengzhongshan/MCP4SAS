/* R584 sql_intersect, N=5; source: SAS-Useful-Codes/Macros/SAS-macros-master/insect.sas:4 */

data r584a; do x=1 to 2*5; output; end; run;
data r584b; do x=5 to 3*5; output; end; run;
proc sql; create table r584c as select x from r584a intersect select x from r584b;
create table r584o as select sum(x) as actual from r584c; quit;

data _null_; if 0 then set r584o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R584 rows=' rows;
else do; set r584o; if not missing(actual) and abs(actual-(45))<=1e-10*max(1,abs(45)) then put 'ROUND2_PASS=R584';
else put 'ERROR: ROUND2_FAIL=R584 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r584:; quit;
