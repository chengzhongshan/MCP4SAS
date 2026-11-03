/* J3746 by_notsorted_run_count, N=7; source: Step-by-Step Programming with Base SAS Software.txt:6195 */

data j3746a; do run=1 to 3; grp=mod(run,2); do j=1 to 7; output; end; end; run;
data j3746b; set j3746a; by grp notsorted; if first.grp; run;
proc sql; create table j3746o as select count(*) as actual from j3746b; quit;

data _null_; if 0 then set j3746o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3746 rows=' rows;
else do; set j3746o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND8_PASS=J3746';
else put 'ERROR: ROUND8_FAIL=J3746 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3746:; quit;
