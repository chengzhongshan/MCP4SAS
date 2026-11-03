/* J3741 by_notsorted_run_count, N=2; source: Step-by-Step Programming with Base SAS Software.txt:6195 */

data j3741a; do run=1 to 3; grp=mod(run,2); do j=1 to 2; output; end; end; run;
data j3741b; set j3741a; by grp notsorted; if first.grp; run;
proc sql; create table j3741o as select count(*) as actual from j3741b; quit;

data _null_; if 0 then set j3741o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3741 rows=' rows;
else do; set j3741o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND8_PASS=J3741';
else put 'ERROR: ROUND8_FAIL=J3741 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3741:; quit;
