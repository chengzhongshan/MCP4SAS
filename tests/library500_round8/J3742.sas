/* J3742 by_notsorted_run_count, N=3; source: Step-by-Step Programming with Base SAS Software.txt:6195 */

data j3742a; do run=1 to 3; grp=mod(run,2); do j=1 to 3; output; end; end; run;
data j3742b; set j3742a; by grp notsorted; if first.grp; run;
proc sql; create table j3742o as select count(*) as actual from j3742b; quit;

data _null_; if 0 then set j3742o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3742 rows=' rows;
else do; set j3742o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND8_PASS=J3742';
else put 'ERROR: ROUND8_FAIL=J3742 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3742:; quit;
