/* J3749 by_notsorted_run_count, N=10; source: Step-by-Step Programming with Base SAS Software.txt:6195 */

data j3749a; do run=1 to 3; grp=mod(run,2); do j=1 to 10; output; end; end; run;
data j3749b; set j3749a; by grp notsorted; if first.grp; run;
proc sql; create table j3749o as select count(*) as actual from j3749b; quit;

data _null_; if 0 then set j3749o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3749 rows=' rows;
else do; set j3749o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND8_PASS=J3749';
else put 'ERROR: ROUND8_FAIL=J3749 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3749:; quit;
