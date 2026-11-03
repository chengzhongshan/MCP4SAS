/* J3750 by_notsorted_run_count, N=11; source: Step-by-Step Programming with Base SAS Software.txt:6195 */

data j3750a; do run=1 to 3; grp=mod(run,2); do j=1 to 11; output; end; end; run;
data j3750b; set j3750a; by grp notsorted; if first.grp; run;
proc sql; create table j3750o as select count(*) as actual from j3750b; quit;

data _null_; if 0 then set j3750o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3750 rows=' rows;
else do; set j3750o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND8_PASS=J3750';
else put 'ERROR: ROUND8_FAIL=J3750 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3750:; quit;
