/* J3748 by_notsorted_run_count, N=9; source: Step-by-Step Programming with Base SAS Software.txt:6195 */

data j3748a; do run=1 to 3; grp=mod(run,2); do j=1 to 9; output; end; end; run;
data j3748b; set j3748a; by grp notsorted; if first.grp; run;
proc sql; create table j3748o as select count(*) as actual from j3748b; quit;

data _null_; if 0 then set j3748o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3748 rows=' rows;
else do; set j3748o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND8_PASS=J3748';
else put 'ERROR: ROUND8_FAIL=J3748 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3748:; quit;
