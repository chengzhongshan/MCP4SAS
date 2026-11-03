/* J3744 by_notsorted_run_count, N=5; source: Step-by-Step Programming with Base SAS Software.txt:6195 */

data j3744a; do run=1 to 3; grp=mod(run,2); do j=1 to 5; output; end; end; run;
data j3744b; set j3744a; by grp notsorted; if first.grp; run;
proc sql; create table j3744o as select count(*) as actual from j3744b; quit;

data _null_; if 0 then set j3744o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3744 rows=' rows;
else do; set j3744o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND8_PASS=J3744';
else put 'ERROR: ROUND8_FAIL=J3744 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3744:; quit;
